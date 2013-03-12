class Admin::BaseController < ApplicationController
  include Controllers::Pagination

  layout 'admin/application'

  before_filter :authenticate_admin!
  before_filter :build_breadcrumbs

  responders :flash

  helper 'admin/layout'

  class << self

    # Sets navigation section appropriate for this controller
    # (actually sets instance variable @navigation_section using before filter)
    #
    # @param section [String] section name.
    # @param options [Hash] see before_filter options.
    #
    def navigation_section(section, options = {})
      before_filter(options) do |controller|
        controller.instance_variable_set('@navigation_section', section)
      end
    end
  end

  protected

  # Builds breadcrumbs for admin controllers. Not designed to work with nested resources.
  #
  def build_breadcrumbs
    @breadcrumbs = [
        { :title => I18n.t("admin.sections.#{resource_collection_name}"), :url => collection_path }
    ]
    @breadcrumbs << { :title => params[:action] } unless params[:action] == 'index'
  end

  #  Before filter, which should be used in case you want to include Google's Maps API to your page
  #
  def with_google_maps_api
    @include_goole_maps = true
  end
end