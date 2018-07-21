require 'net/http'
require 'uri'
require 'json'

class LightningChargeService
  def self.invoice_uri(lightning_charge_id=nil)
    if lightning_charge_id.nil?
      return URI.parse("#{ ENV["LIGHTNING_CHARGE_URL"] || "http://localhost:9112" }/invoice")
    else
      return URI.parse("#{ ENV["LIGHTNING_CHARGE_URL"] || "http://localhost:9112" }/invoice/#{ lightning_charge_id }")
    end
  end

  def self.http_request(method, uri)
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

  def self.request_and_parse(request, uri)
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
end
