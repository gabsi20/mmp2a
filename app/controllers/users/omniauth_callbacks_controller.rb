# Handles Authentification
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth request.env['omniauth.auth']
    Token.from_omniauth request.env['omniauth.auth'], @user

    if @user.persisted?
      sign_in @user, :event => :authentication
      if !(current_user.calendars.any?)
        redirect_to '/sync/select'
      else
        redirect_to '/tasks'
      end
      set_flash_message :notice,
                        :success,
                        :kind => 'Google' if is_navigational_format?
    else
      set_flash_message :notice,
                        :failure,
                        :kind => 'Google',
                        :reason => 'error' if is_navigational_format?
      redirect_to root_path
    end
  end

  def failure
    redirect_to root_path
  end
end