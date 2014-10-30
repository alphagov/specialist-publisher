module Kaminari
  module Helpers
    class Tag
      def page_url_for(page)
        doc_type = @params[:document_type]
        other_params = @params.except(:document_type).merge(@param_name => (page <= 1 ? nil : page), :only_path => true)

        route_helper = "#{doc_type.pluralize}_path"

        @template.send(route_helper, other_params)
      end
    end
  end
end
