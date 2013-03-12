module Admin::LayoutHelper

  # Gets title for admin area.
  #
  def admin_area_title
    "#{I18n.t('application.title')} :: #{I18n.t('application.admin_area')}"
  end

  # Renders navigation item for top admin menu.
  #
  # @param section [Symbol] navigation section appropriate to this item. See Admin::BaseController.navigation_section.
  #                         Uses to determines whether item should be highlighted as active.
  # @param path [String] menu item navigation path.
  #
  # @return [String] html markup.
  #
  def navigation_item(section, path)
    content_tag(:li, link_to(I18n.t("admin.sections.#{section}"), path), :class => (section == @navigation_section) ? 'active' : '')
  end
end