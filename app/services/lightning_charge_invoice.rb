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
    info = client.fetch_invoice(id)

    @status = info['status']
  end

  def create(amount)
    info = client.create_invoice(amount)

    @status = info['status']
    @id = info['id']
  end

  private

  def client
    LightningChargeClient.new
  end
end
