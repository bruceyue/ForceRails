
#require "rack/ssl" unless ENV['RACK_ENV'] == "development"
module OpenSSL
  module SSL
    remove_const :VERIFY_PEER
  end
end
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class SalesforceSandbox < OmniAuth::Strategies::Salesforce
  default_options[:client_options][:site] = 'https://test.salesforce.com/'
end

class DatabaseDotCom < OmniAuth::Strategies::Salesforce
  default_options[:client_options][:site] = 'https://login.database.com/'
end

class SalesforcePreRelease < OmniAuth::Strategies::Salesforce
  default_options[:client_options][:site] = 'https://prerellogin.pre.salesforce.com/'
end


Rails.application.config.middleware.use OmniAuth::Builder do

  #OmniAuth.config.logger = Rails.logger
  #use Rack::SSL unless ENV['RACK_ENV'] == "development"
  #use Rack::Session::Pool

  #OmniAuth.config.on_failure do |env|
    #[302, {'Location' => "/auth/failure?message=#{env['omniauth.error.type']}"}, ["Redirecting..."]]
  #end

  # login.salesforce.com
  provider :salesforce,
               ENV['SALESFORCE_KEY']='3MVG9Y6d_Btp4xp4CbfgVpUoAB2fBp_Ob6jn.alYUgjV0QMBfJkEvye6B9x8vTxrEXh..NTUvdzBtNVFVKjvB',
               ENV['SALESFORCE_KEY']='6431398207181831221' #heroku key
               #ENV['SALESFORCE_KEY']='3MVG9Y6d_Btp4xp4CbfgVpUoAB.AJ9UJYoDABdPVlPmwq8_82exgAzKJwXRaEH7rmtFCk6rhdm0jiWGypH.jN',
               #ENV['SALESFORCE_KEY']='9044592759507549551'


  # test.salesforce.com
  provider OmniAuth::Strategies::SalesforceSandbox,
               ENV['SALESFORCE_SANDBOX_KEY']='3MVG9Oe7T3Ol0ea4hvXcfVe00rEJphHtdBWjZj6UBapH3cvBSbHjDsw9zFBVpIpCM.E.tGixMT.6Clnm9OEs0',
               ENV['SALESFORCE_SANDBOX_SECRET']='8941888887350760246' #Heroku Key
               #ENV['SALESFORCE_SANDBOX_KEY']='3MVG9Oe7T3Ol0ea4hvXcfVe00rNFk6Uby8UTsq6nlrFPwMqz2R8dblAp6_rEhJNsiRi1.yOuKCZs3IMX3w.2O',
               #ENV['SALESFORCE_SANDBOX_SECRET']='1219635684737453890'

  provider OmniAuth::Strategies::SalesforcePreRelease,
               ENV['SALESFORCE_PRERELEASE_KEY'],
               ENV['SALESFORCE_PRERELEASE_SECRET']

  provider OmniAuth::Strategies::DatabaseDotCom,
               ENV['DATABASE_DOT_COM_KEY'],
               ENV['DATABASE_DOT_COM_SECRET']
end

