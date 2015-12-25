class PagesController < ApplicationController
  def show 
  	render template: "pages/index.html"
  end
  def show 
  	render template: "pages/#{params[:page]}"
  end
end
