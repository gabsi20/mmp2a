# Handles Static sites
class PagesController < ApplicationController
  layout "ios_application", only: [:ios_login]

  def index
    if current_user
      redirect_to tasks_path
    else
      render template: 'pages/index.html'
    end
  end

  def ios_login
    if current_user
      redirect_to tasks_path
    else
      render template: 'pages/index.html'
    end
  end

  def show
    render template: 'pages/#{params[:page]}'
  end
end
