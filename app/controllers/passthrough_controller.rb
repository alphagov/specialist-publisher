class PassthroughController < ApplicationController
  after_action :skip_authorization

  def index
    if first_permitted_format
      redirect_to documents_path(document_type_slug: first_permitted_format.slug)
    else
      redirect_to error_path
    end
  end

  def error; end

private

  def first_permitted_format
    @first_permitted_format ||= formats_user_can_access.sort_by(&:name).find do |document_class|
      DocumentPolicy.new(current_user, document_class).index?
    end
  end
end
