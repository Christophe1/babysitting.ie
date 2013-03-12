module Controllers
  module Pagination
    extend ActiveSupport::Concern

    module ClassMethods

      # Makes controller paginated.
      #
      def paginated
        self.send(:include, Controllers::Pagination::PaginationMethods)
      end
    end

    module PaginationMethods

      # Gets collection paginated.
      #
      def collection
        get_collection_ivar || set_collection_ivar(end_of_association_chain.paginate(:page => params[:page]))
      end
    end
  end
end