OmniAuth.config.full_host = Rails.env.production? ? 'https://domain.com' : 'http://localhost:3000'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'],
           :scope => 'email', :info_fields => 'email,first_name,last_name'

  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']

  provider :google_oauth2, ENV["GOOGLE_KEY"], ENV["GOOGLE_SECRET"], {
  	:scope => 'email,profile'
  }
end