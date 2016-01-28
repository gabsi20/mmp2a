class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth request.env["omniauth.auth"]
    Token.from_omniauth request.env["omniauth.auth"], @user

    if @user.persisted?
      sign_in @user, :event => :authentication #this will throw if @user is not activated
      redirect_to '/tasks'
      set_flash_message :notice, :success, :kind => "Google" if is_navigational_format?
    else
      set_flash_message :notice, :failure, :kind => "Google", :reason => "something went wrong" if is_navigational_format?
      redirect_to root_path
    end
  end

  def failure
    redirect_to root_path
  end
end