class AbstractDocumentsController < ApplicationController
  before_filter :authorize_user_for_editing
  before_filter :authorize_user_for_publishing, only: [:publish]
  before_filter :authorize_user_for_withdrawing, only: [:withdraw]

  rescue_from("SpecialistDocumentRepository::NotFoundError") do
    redirect_to(index_path, flash: { error: "Document not found" })
  end

  def index
    documents = services.list.call.map { |d| view_adapter(d) }

    paginated_docs = Kaminari.paginate_array(documents).page(params[:page])

    render("specialist_documents/index", locals: { documents: paginated_docs })
  end

  def show
    document = services.show(document_id).call

    render("specialist_documents/show", locals: { document: view_adapter(document) })
  end

  def new
    document = services.new.call

    render("specialist_documents/new", locals: { document: view_adapter(document) })
  end

  def edit
    document = services.show(document_id).call

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

    if document.errors[:body].nil?
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

  def document_params
    raise NotImplementedError
  end

  def view_adapter(document)
    raise NotImplementedError
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

  def services
    raise NotImplementedError
  end

  def index_path
    raise NotImplementedError
  end

  def show_path(document)
    raise NotImplementedError
  end
end
