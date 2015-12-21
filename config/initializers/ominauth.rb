Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'],
           :scope => 'email', :info_fields => 'email,first_name,last_name'

  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end