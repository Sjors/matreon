require 'net/http'
require 'uri'
require 'json'

class LightningChargeInvoice
  attr_reader :id, :status

  def initialize(id = nil)
    @id = id
  end

  def self.find(id)
    instance = new(id)
    instance.fetch_info

    instance
  end

  def self.create(amount)
    instance = new
    instance.create(amount)

    instance
  end

  def fetch_info
    request = http_request("GET", invoice_uri)
    info = request_and_parse(request)

    @status = info['status']
  end

  def create(amount)
    request = http_request('POST', invoice_uri)
    request.set_form_data({
      msatoshi: amount * 1000,
      description: "Matreon",
      expiry: 60 * 60 * 24 * 7 # 1 week, TODO: add invoices.expires_at
    })
    info = request_and_parse(request)

    @status = info['status']
    @id = info['id']
  end

  private

  def lightning_charge_host
    ENV["LIGHTNING_CHARGE_URL"] || "http://localhost:9112"
  end

  def invoice_uri
    if id.nil?
      URI.parse("#{lightning_charge_host}/invoice")
    else
      URI.parse("#{lightning_charge_host}/invoice/#{id}")
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

    request
  end

  def request_and_parse(request)
    http = Net::HTTP.new(invoice_uri.host, invoice_uri.port)
    response = http.request(request)

    unless ["200", "201"].include?(response.code)
      puts response.code
      puts response.body
      throw "Failed to make request to lightning charge"
    else
      JSON.parse(response.body)
    end
  end
end
