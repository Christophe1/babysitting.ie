module Responders::PaginatedResponder
  def to_format
    if get? && resource.is_a?(ActiveRecord::Relation)
      controller.paginated_scope
    end
    super
  end
end