class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  require 'httparty'

  skip_before_filter :verify_authenticity_token

  def google_oauth2
    # debugger
    # if params[:code]
    #   options = {
    #     query: {
    #       code: params[:code],
    #       redirect_uri: user_omniauth_callback_url(:google_oauth2),
    #       client_id: ENV['GOOGLE_CLIENT_ID'],
    #       client_secret: ENV['GOOGLE_CLIENT_SECRET'],
    #       grant_type: "authorization_code"
    #     }
    #   }
    #   response = HTTParty.post('https://www.googleapis.com/oauth2/v3/token', options)
    # end
    # debugger
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end