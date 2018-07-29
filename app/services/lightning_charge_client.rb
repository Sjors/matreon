class LightningChargeClient
  def fetch_invoice(invoice_id)
    uri = invoice_uri(invoice_id)

    request = http_request("GET", uri)
    request_and_parse(uri, request)
  end

  def create_invoice(amount)
    uri = invoice_uri

    request = http_request('POST', uri)
    request.set_form_data({
      msatoshi: amount * 1000,
      description: "Matreon",
      expiry: 60 * 60 * 24 * 7 # 1 week, TODO: add invoices.expires_at
    })
    request_and_parse(uri, request)
  end

  private

  def lightning_charge_host
    ENV["LIGHTNING_CHARGE_URL"] || "http://localhost:9112"
  end

  def invoice_uri(invoice_id = nil)
    if invoice_id.nil?
      URI.parse("#{lightning_charge_host}/invoice")
    else
      URI.parse("#{lightning_charge_host}/invoice/#{invoice_id}")
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

  def request_and_parse(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
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
