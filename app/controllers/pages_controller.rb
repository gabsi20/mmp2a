class PagesController < ApplicationController
  def index 
  	render template: "pages/index.html"
  end
  def show 
  	render template: "pages/#{params[:page]}"
  end
end
