class ApplicationController < ActionController::Base

  protect_from_forgery

  layout :layout_by_resource

  # Overrides default devise behaviour to provide custom path after admin sign out.
  #
  # @param resource [String] resource name.
  #
  # @return [String] path to redirection after sign out.
  #
  def after_sign_out_path_for(resource)
    if resource.to_sym == :admin
      new_admin_session_path
    else
      super
    end
  end

  # Overrides default devise behaviour to provide custom path after user sign in.
  #
  # @param resource_or_scope [String] resource or scope name.
  #
  # @return [String] path to redirection after sign in.
  #
  def signed_in_root_path(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    if scope.to_sym == :user
      landing_page
    else
      super
    end
  end

  # Returns landing page for user. Doesn't use any redirects.
  # Should be used by logged in users only
  #
  def landing_page
    current_user.registration_complete? ? user_path(current_user) : map_path
  end

  helper_method :landing_page

  protected

  #  Before filter, which should be used in case you want to include Google's Maps API to your page
  #
  def with_google_maps
    @include_goole_maps = true
  end

  def layout_by_resource
    if devise_controller? && resource_name == :user
      "devise"
    else
      "application"
    end
  end

end
