require 'net/http'
require 'uri'
require 'json'

class Invoice < ApplicationRecord
  belongs_to :user

  before_create :create_lightning_charge_invoice
  before_update :update_lightning_charge_invoice

  scope :this_month, -> { where('created_at >= ?', 1.month.ago) }

  def as_json(options = nil)
    super({ only: [:id, :amount, :paid_at, :status, :created_at, :polled_at] }.merge(options || {})).merge({url: url})
  end

  def url
    return nil if !charge_invoice_id
    return "#{ ENV["LIGHTNING_CHARGE_URL"] }/checkout/#{ charge_invoice_id}"
  end

  def poll!
    return false if !charge_invoice_id
    return false if status != "unpaid"

    uri = invoice_uri(charge_invoice_id)
    request = http_request("GET", uri)

    invoice = request_and_parse(request, uri)

    self.update status: invoice["status"], polled_at: DateTime.now, paid_at: invoice["status"] == "paid" ? DateTime.now : nil
    
    return invoice
  end

  def self.generate!
    Contribution.non_zero.each do | contribution |
      contribution.create_or_update_invoice!
    end
  end

  def self.email!
  end

  private

  def invoice_uri(lightning_charge_id=nil)
    if lightning_charge_id.nil?
      return URI.parse("#{ ENV["LIGHTNING_CHARGE_URL"] }/invoice")
    else
      return URI.parse("#{ ENV["LIGHTNING_CHARGE_URL"] }/invoice/#{ lightning_charge_id }")
    end
  end

  def http_request(method, uri)
    if method == "GET"
      request = Net::HTTP::Get.new(uri.request_uri)
    elsif method == "POST"
      request = Net::HTTP::Post.new(uri.request_uri)
    else
      throw "Unknown type"
    end

    request.basic_auth("api-token", ENV["LIGHTNING_CHARGE_API_TOKEN"])

    return request
  end

  def request_and_parse(request, uri)
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(request)

    if !["200", "201"].include? (response.code)
      puts response.code
      puts response.body
      throw "Failed to make request to lightning charge"
    else
      return JSON.parse(response.body)
    end
  end

  def create_lightning_charge_invoice
    uri = invoice_uri()

    invoice = {
      msatoshi: amount * 1000,
      description: "Matreon",
      expiry: 60 * 60 * 24 * 7 # 1 week
    }
  
    request = http_request("POST", uri)

    request.set_form_data(invoice)

    generated_invoice = request_and_parse(request, uri)

    self.charge_invoice_id = generated_invoice["id"]
    self.status = generated_invoice["status"]
    self.polled_at = DateTime.now
  end

  def update_lightning_charge_invoice
    if amount_changed? # Create new lightning invoice
      create_lightning_charge_invoice
    end
  end

end
