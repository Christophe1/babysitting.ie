module ApplicationHelper

  # Determines current step by controller and action.
  #
  def current_step
    if params[:controller] == "home"
      :sign_in
    elsif params[:controller] == "my_films"
      :my_page
    elsif params[:controller] == "films"
      :see_friends_films
    end
  end

  # Determines whether step specified is current step.
  #
  # @param step [Symbol] step to check.
  #
  # @return [Boolean] true if step is current step and false otherwise.
  #
  def is_current_step?(step)
    current_step == step
  end

  # Generates html markup for site navigation.
  #
  # @param step [Symbol] step name.
  # @param path [String] navigation path.
  #
  # @return [String] html markup for step specified.
  #
  def step_tab(step, path)
    text = I18n.t("wizard.#{step}")
    if !is_current_step?(step)
      text = link_to(text, path)
    end
    content_tag(:li, text, :class => (is_current_step?(step) ? 'active' : ''))
  end

  # Renders flash :notice and :error messages.
  #
  def show_messages
    "jQuery('#messages').replaceWith('#{escape_javascript(render('layouts/messages'))}');".html_safe
  end

  # Generate html markup for Facebook login button.
  #
  # @param text [String] button text.
  # @param options [Hash] additional options.
  #
  # @return [String] html markup.
  #
  def fb_login_button(text, options = {})
    link_to(text, user_omniauth_callback_path(:facebook), { 'class' => 'fb-login', 'data-scope' => OAUTH_CONFIG['facebook']['options']['scope'] }.merge(options))
  end

  # Returns user name or 'me' if user is currently logged in.
  #
  # @param user [User] application user.
  #
  # @return [String] user name or 'me'.
  #
  def user_name(user)
    current_user == user ? I18n.t('helpers.me') : user.name
  end

  # Generates facebook avatar image tag.
  #
  # @param user [User] application user.
  # @param options [Hash] additional options to image tag.
  #
  # @return [String] html markup.
  #
  def fb_avatar(user, options = {})
    link_to(image_tag("http://graph.facebook.com/#{user.external_user_id}/picture?type=square", { :alt => user_name(user), :class => 'fb-avatar' }.merge(options)), "http://www.facebook.com/profile.php?id=#{user.external_user_id}", { :target => '_blank' })
  end

  # Generates profile link tag.
  #
  # @param user [User] application user.
  # @param options [Hash] additional options to link tag.
  #
  # @return [String] html markup.
  #
  def fb_profile_link(user, options = {})
    link_to(user_name(user), "http://www.facebook.com/profile.php?id=#{user.external_user_id}", { :target => '_blank' }.merge(options))
  end

  # Generates html markup for film comments title.
  #
  # @param film_user [FilmUser] film user object.
  #
  # @return [String] html markup.
  #
  def film_review_title(film_user)
    I18n.t('films.review_title', :user => fb_profile_link(film_user.user), :genres => film_user.genres_list).html_safe
  end

  # Generates html markup for mutual friends indicator.
  #
  # @param mutual_friends_ids [Array] list of mutual friends ids.
  # @param translation_key [String] key in translation file for link content.
  #
  # @return [String] html markup.
  #
  def mutual_friends_link(mutual_friends_ids, translation_key = 'application.mutual_friends')
    if mutual_friends_ids.present?
      link_to(t(translation_key, :count => mutual_friends_ids.size), '#', 'data-ids' => mutual_friends_ids[0, SocialNetwork::FACEBOOK_INVITE_LIMIT].join(','))
    end
  end

  # Generates html markup for timestamp (including word representation of time interval).
  #
  # @param time [DateTime] time in the past.
  #
  # @return [String] html markup.
  #
  def time_ago(time)
    content_tag(:abbr, I18n.t('helpers.time_ago', :time => time_ago_in_words(time)), :title => I18n.l(time.localtime, :format => :long), :class => 'time-ago grey')
  end

  # Converts lone breaks to br tags.
  #
  # @param [String] text with line breaks from text area.
  #
  # @return [String] html formatted text with <br/> tags.
  #
  def text_area_to_html(text)
    if text
      html_escape(text).gsub(/\r\n?/, "\n").gsub(/\n/, '<br />').html_safe
    end
  end

  # Creates a button tag using name and options to handle ajax actions with UJS.
  # It's alternative of rendering form tag with :remote => true. Options are similar to link_to tag.
  #
  def link_button_to(*args, &block)
    if block_given?
      options      = args.first || {}
      html_options = args.second
      link_button_to(capture(&block), options, html_options)
    else
      name         = args[0]
      options      = args[1] || {}
      html_options = args[2]

      url = url_for(options)
      html_options = convert_options_to_data_attributes(options, html_options.merge({ 'data-url' => url }))

      content_tag(:button, ERB::Util.html_escape(name || url), html_options)
    end
  end

  def welcome_text
    friends_count = User.followers_for(current_user).size
    friends = if friends_count == 0
      t('application.no_friends')
    elsif friends_count == 1
      t('application.friend')
    else
      t('application.friends', :count => friends_count)
    end
    invitation_text = if friends_count == 0
      t('application.invite_friends_on')
    else
      t('application.invite_other_on')
    end
    t('application.welcome', :user => current_user.first_name, :friends => friends, :invitation_text => invitation_text,
                             :email_invite_link => link_to(t('helpers.links.email'), '#', :class => 'email-invite-link')).html_safe
  end

  # Renders avatars of random facebook friends.
  #
  # @param user [User] current user.
  # @param limit [Fixnum] maximum friends number to display.
  #
  # @return [String] html markup.
  #
  def friends_avatars(user, limit = 4)
    avatars = user.random_facebook_friends(limit).map do |friend|
      fb_avatar(friend)
    end
    avatars.join('').html_safe
  end
end
