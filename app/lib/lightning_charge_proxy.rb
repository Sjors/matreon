class LightningChargeProxy < Rack::Proxy
  def rewrite_env(env)
    env['HTTP_HOST'] = 'charge'
    env['SERVER_PORT'] = 9112
    env
  end
end
