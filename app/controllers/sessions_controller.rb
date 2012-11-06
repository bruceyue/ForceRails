=begin
/************* CODE CATS ARE NOT AMUSED *****************

        *     ,MMM8&&&.            *
            MMMM88&&&&&    .
            MMMM88&&&&&&&
 *          MMM88&&&&&&&&
            MMM88&&&&&&&&
            'MMM88&&&&&&'
              'MMM8&&&'        *     _
     |\___/|                          \\
    =) ^Y^ (=        |\_/|             ||    '
     \  ^  /         )a a '._.-""""-.  //
      )=*=(         =\T_= /    ~  ~  \//
     /     \          `"`\   ~   / ~  /
     |     |              |~   \ |  ~/
    /| | | |\             \  ~/- \ ~\
    \| | |_|/|            || |  // /`
 jgs_/\_//_// __//\_/\_/\_((_|\((_//\_/\_/\_
 |  |  |  | \_) |  |  |  |  |  |  |  |  |  |
 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |

 *******************************************************/
=end
#http://wiki.developerforce.com/page/Digging_Deeper_into_OAuth_2.0_on_Force.com
class SessionsController < ApplicationController
	before_filter :require_login, :except => [:create, :failure]
	#login
	def create
		auth_hash = request.env["omniauth.auth"] #=> OmniAuth::AuthHash
    user = User.find_or_create_context_user(auth_hash)

    if user
      session[:user_id] = user.id # local db model user id used for user identification, not available to browser
      cookies[:user_id] = user.user_id # SFDC user id, used for creating the view, available to browser code
      flash[:notice] = "Welcome #{user.name}"
      #redirect_to accounts_path
      redirect_to_target_or_default root_url, :notice => "Signed in successfully. Welcome #{user.name}"
    else  # this should never happen
      Rails.logger.error "No user after login via Salesforce"
      flash[:error] = "No user after login via Salesforce"
      redirect_to root_path
    end
	end

	# OAuth application approval failed - user clicked "Deny" on OAuth dialog
  # and Omniauth sends the user here.
  def failure
    flash[:error] = params[:message] # putting the error on the redirect doens't work!
    flash[:error] << ". Note that if the Salesforce organization you are authenticating against has IP or other login restrictions, you cannot use it with this application."
    redirect_to root_path
  end

	# user signs out of this app (not salesforce). Delete the cookie.
  # Note that the app still has an access token and refresh token so can
  # still hit the api for notifications.
  def destroy
    reset_session
    redirect_to root_path
  end
end
