require "specialist_publisher"

class AbstractDocumentsController < ApplicationController
  before_filter :authorize_user_for_editing
  before_filter :authorize_user_for_publishing, only: [:publish]
  before_filter :authorize_user_for_withdrawing, only: [:withdraw]

  rescue_from("SpecialistDocumentRepository::NotFoundError") do
    redirect_to(index_path, flash: { error: "Document not found" })
  end

  def index
    documents = services.list(search_adapter).call.map { |d| view_adapter(d) }

    truncate_and_warn(documents) if searching? && documents.size >= max_per_page

    flash.now[:alert] = "Your search returned 0 results." if searching? && documents.size == 0

    paginated_docs = Kaminari.paginate_array(documents).page(params[:page])

    render("specialist_documents/index", locals: {
      documents: paginated_docs,
    })
  end

  def show
    document, other_metadata = services.show(document_id).call
    slug_unique = other_metadata.fetch(:slug_unique)
    publishable = other_metadata.fetch(:publishable)

    unless slug_unique
      flash.now[:error] = "Warning: This document's URL is already used on GOV.UK. You can't publish it until you change the title."
    end

    render("specialist_documents/show", locals: {
      document: view_adapter(document),
      slug_unique: slug_unique,
      publishable: publishable,
    })
  end

  def new
    document = services.new.call

    render("specialist_documents/new", locals: { document: view_adapter(document) })
  end

  def edit
    document, _metadata = services.show(document_id).call

    render("specialist_documents/edit", locals: { document: view_adapter(document) })
  end

  def create
    document = services.create(document_params).call

    if document.valid?
      redirect_to(show_path(document))
    else
      render("specialist_documents/new", locals: { document: view_adapter(document) })
    end
  end

  def update
    document = services.update(document_id, document_params).call

    if document.valid?
      redirect_to(show_path(document))
    else
      render("specialist_documents/edit", locals: { document: view_adapter(document) })
    end
  end

  def publish
    document = services.publish(document_id).call

    redirect_to(
      show_path(document),
      flash: { notice: "Published #{document.title}" }
    )
  end

  def withdraw
    document = services.withdraw(document_id).call

    redirect_to(
      show_path(document),
      flash: { notice: "Withdrawn #{document.title}" }
    )
  end

  def preview
    document = services.preview(params["id"], document_params).call

    document.valid? # Force validation check or errors will be empty

    if document.errors[:body].blank?
      render json: { preview_html: document.body }
    else
      render json: {
        preview_html: render_to_string(
          "shared/_preview_errors",
          layout: false,
          locals: {
            errors: document.errors[:body]
          }
        )
      }
    end
  end

private
  def max_per_page
    @max_per_page ||= Kaminari.config.default_per_page
  end

  def truncate_and_warn(documents)
    flash.now[:alert] = "Your search returned #{documents.size} results. Only the first #{max_per_page} are shown."
    documents = documents.first(max_per_page)
  end

  def searching?
    search_query.present?
  end

  def search_adapter
    OpenStruct.new(query: search_query)
  end

  def search_query
    params.fetch(:query, nil)
  end

  def document_id
    params.fetch("id")
  end

  def filtered_params(params_of_document)
    # TODO: Make this work like the ManualsController parameter filtering
    # We shouldn't make our hashes indifferent. Let's make the keys consistently symbols
    filter_blank_multi_selects(params_of_document).with_indifferent_access
  end

  # See http://stackoverflow.com/questions/8929230/why-is-the-first-element-always-blank-in-my-rails-multi-select
  def filter_blank_multi_selects(values)
    values.reduce({}) { |filtered_params, (key, value)|
      filtered_value = value.is_a?(Array) ? value.reject(&:blank?) : value
      filtered_params.merge(key => filtered_value)
    }
  end

  def authorize_user_for_editing
    unless current_user_can_edit?(document_type)
      redirect_to(
        manuals_path,
        flash: { error: "You don't have permission to do that." },
      )
    end
  end

  def authorize_user_for_publishing
    unless current_user_can_publish?(document_type)
      redirect_to(
        show_path(document_id),
        flash: { error: "You don't have permission to publish." },
      )
    end
  end

  def authorize_user_for_withdrawing
    unless current_user_can_withdraw?(document_type)
      redirect_to(
        show_path(document_id),
        flash: { error: "You don't have permission to withdraw." },
      )
    end
  end

  def document_params
    filtered_params(params.fetch(document_type, {}))
  end

  def view_adapter(document)
    SpecialistPublisher.view_adapter(document)
  end

  def services
    SpecialistPublisher.document_services(document_type)
  end

  def index_path
    send(resource_name + "_path")
  end

  def show_path(document)
    send(document_type + "_path", document)
  end

  helper_method :document_type
  def document_type
    resource_name.singularize
  end

  helper_method :resource_name
  def resource_name
    request.path.split("/").fetch(1).underscore
  end
end
