VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!

  c.filter_sensitive_data('<LIGHTNING_CHARGE_URL>') { ENV['LIGHTNING_CHARGE_URL'] }
  c.filter_sensitive_data('<LIGHTNING_CHARGE_API_TOKEN>') { ENV['LIGHTNING_CHARGE_API_TOKEN'] }
  c.filter_sensitive_data('<LIGHTNING_CHARGE_BASIC_AUTH>') do
    ActionController::HttpAuthentication::Basic.encode_credentials('api-token', ENV['LIGHTNING_CHARGE_API_TOKEN'])
  end
end
