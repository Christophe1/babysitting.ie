config_path = Rails.root.join("config", "linkedin.yml")
if File.exists?(config_path)
  config = YAML.load_file(config_path)[Rails.env]
else
  Rails.logger.warn("Could not find omnicontacts.yml in config directory.")
end

LinkedIn::Client::APP_KEY = config['app_id']
LinkedIn::Client::APP_SECRET = config['app_secret']

LinkedIn::Client::CONFIGURATION = { :site => 'https://api.linkedin.com',
        :authorize_path => '/uas/oauth/authenticate',
        :request_token_path =>'/uas/oauth/requestToken?scope=r_network+w_messages',
        :access_token_path => '/uas/oauth/accessToken' }

class LinkedIn::Client
  # options should be a hash like this:
  # options = {:recipients => {:values => [:person => {:_path => "/people/~" }, :person => {:_path => "/people/USER_ID"} ]}, :subject => "Something",:body => "To read" }
  def send_message(subject, body, contacts)
    contacts.map! { |contact| { 'person' => { '_path' => "/people/#{contact}" } } }
    options = { :recipients => { :values => contacts}, :subject => subject, :body => body }
    path = "/people/~/mailbox"
    post(path, options.to_json, "Content-Type" => "application/json")
  end

  def authorize!(session)
    authorize_from_access(session[:atoken], session[:asecret])
  end

  def full_name
    "#{profile.first_name} #{profile.last_name}"
  end

  def authorize_url(session, callback_url)
    rtoken = request_token(:oauth_callback => callback_url)
    session[:rtoken] = rtoken.token
    session[:rsecret] = rtoken.secret
    request_token.authorize_url
  end
end