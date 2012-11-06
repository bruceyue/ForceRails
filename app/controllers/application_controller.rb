class ApplicationController < ActionController::Base
  protect_from_forgery #Turn on request forgery protection. Bear in mind that only non-GET, HTML/JavaScript requests are checked.

  #Declare a controller method as a helper, so we can use in the page.
  helper_method :current_user, :logged_in?, :require_user

  API_VERSION = "26.0"

  # returns helpful info depending on the type of API error
  def error_help(error)
    if error.error_code == 'API_DISABLED_FOR_ORG'
      return "Your user may have the API enabled user profile perm off, or your user or org may not have Chatter turned on. Check with your administrator"
    else
      return ''
    end
  end

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue Exception
    Rails.logger.error "User had cookie but no user with that id found in the db-treating as no user found."
    return nil
  end

  def logged_in?
    return current_user != nil
  end

  # filter for pages that may only be visited by users logged in.
  def require_login
    if !current_user
      if request.url =~ %r|/accounts/| # chatter controller
        # /chatter controllers have their own error handler for unauthenticated scenarios because none of the actions
        # refresh the page and thus the redirect will disappear in the XHR or hidden iframe.
        if request.xhr?
          render :text => 'You are not authenticated', :status => '401', :content_type => 'application/json'
        else
          render :render_404, :layout => false
        end
      else
        store_target_location
        flash[:notice] = "Hey friend, please log in first."
        redirect_to root_url
      end
      return false
    else # we have a current user
      setup_api_client
    end
  end

  def redirect_to_target_or_default(default, *options)
    redirect_to(session[:return_to] || default, *options)
    session[:return_to] = nil
  end

  def store_target_location
    session[:return_to] = request.url
  end

  # setup the api client for this web request centrally so that  this
  # client may be used for this user across multiple API requests.
  def setup_api_client
    # see http://rubydoc.info/github/heroku/databasedotcom/master/Databasedotcom/Client:initialize
    # add :debugging => true to constructor hash to log API request/responses
    #u = current_user
    #debugger
    @client = Databasedotcom::Client.new({})
    @client.version = API_VERSION
    @client.authenticate :token => @current_user.access_token,
                         :refresh_token => @current_user.refresh_token,
                         :instance_url => @current_user.instance_url
    @client.materialize("Account")
  end

  def render_404
    render_optional_error_file(404)
  end

  def render_500
    render_optional_error_file(500)
  end

  def render_403
    render_optional_error_file(403)
  end

  def render_optional_error_file(status_code)
    status = status_code.to_s
    Rails.logger.error $! # logs the exception object
    if ["404","403", "422", "500"].include?(status)
      render :file => "#{Rails.root}/public/#{status}", :format => [:html], :handler => [:erb], :status => status, :layout => "application"
    else
      render :file => "#{Rails.root}/public/unknown", :format => [:html], :handler => [:erb], :status => status, :layout => "application"
    end
  end

end
