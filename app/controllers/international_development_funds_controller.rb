require "international_development_fund_service_registry"

class InternationalDevelopmentFundsController < AbstractDocumentsController
private
  def view_adapter(document)
    InternationalDevelopmentFundViewAdapter.new(document)
  end

  def authorize_user
    unless user_can_edit_international_development_funds?
      redirect_to(
        manuals_path,
        flash: { error: "You don't have permission to do that." },
      )
    end
  end

  def services
    InternationalDevelopmentFundServiceRegistry.new
  end

  def document_params
    filtered_params(params.fetch("international_development_fund", {}))
  end

  def index_path
    international_development_funds_path
  end

  def show_path(document)
    international_development_fund_path(document)
  end
end
