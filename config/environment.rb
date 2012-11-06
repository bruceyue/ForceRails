# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ForceRails::Application.initialize!

#gem "encryptor"
# used in user.rb model: sets what encryption key to use
Encryptor.default_options.merge!(:key => ForceRails::Application.config.secret_token)

Rails.logger = Logger.new(STDOUT)

