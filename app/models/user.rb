class User < ActiveRecord::Base
  #validates :email, :presence => true, :uniqueness => true

  # will create a new user and save their access token and other info
  # whenever anyone initiates the oauth process.
=begin
  # File activerecord/lib/active_record/relation/finder_methods.rb, line 262
  def find_by_attributes(match, attributes, *args)
    conditions = Hash[attributes.map {|a| [a, args[attributes.index(a)]]}]
    result = where(conditions).send(match.finder)

    if match.bang? && result.blank?
      raise RecordNotFound, "Couldn't find #{@klass.name} with #{conditions.to_a.collect {|p| p.join(' = ')}.join(', ')}"
    else
      yield(result) if block_given?
      result
    end
  end
=end
  def self.find_or_create_context_user(auth_hash)
    user = User.find_by_identity_url(auth_hash['uid'])
    user = User.new if !user
    # save OAuth credentials and user info after every authentication
    # because both may change over time.
    user.instance_url     = auth_hash['credentials']['instance_url']
    user.refresh_token    = auth_hash['credentials']['refresh_token']
    user.access_token     = auth_hash['credentials']['token']
    user.identity_url     = auth_hash['uid']
    user.user_name        = auth_hash['extra']['username']
    user.name             = auth_hash['extra']['display_name']
    user.organization_id  = auth_hash['extra']['organization_id']
    user.user_id          = auth_hash['extra']['user_id']
    user.email            = auth_hash['extra']['email']
    user.first_name       = auth_hash['extra']['first_name']
    user.last_name        = auth_hash['extra']['last_name']
    user.save!
    user
  end

  # uses the Encryptor gem: see https://github.com/shuber/encryptor
  # setter method to encrypt token
  def refresh_token=(raw_token)
    write_attribute(:refresh_token, raw_token.encrypt)
  end

  # getter method to decrypt token
  def refresh_token
    read_attribute(:refresh_token).decrypt
  end

  # setter method to encrypt token
  def access_token=(raw_token)
    write_attribute(:access_token, raw_token.encrypt)
  end

  # getter method to decrypt token
  def access_token
    read_attribute(:access_token).decrypt
  end
end