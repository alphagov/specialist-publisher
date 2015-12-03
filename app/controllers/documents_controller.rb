require 'gds_api/publishing_api_v2'

class DocumentsController <  ApplicationController
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  def index
    unless params[:document_type]
      redirect_to "/#{document_types.keys.first}"
      return
    end

    @documents = publishing_api.get_content_items(
      content_format: current_format.format_name,
      fields: [
        :base_path,
        :content_id,
        :title,
        :public_updated_at,
      ]
    ).to_ostruct
  end

  def new
    render :new, locals: { document: document_klass.new }
  end

  def create
    document = document_klass.new(
      filtered_params(params[current_format.format_name])
    )

    if document.valid?
      presented_document = DocumentPresenter.new(document)
      presented_links = DocumentLinksPresenter.new(document)

      item_request = publishing_api.put_content(document.content_id, presented_document.to_json)
      links_request = publishing_api.put_links(document.content_id, presented_links.to_json)

      if item_request.code == 200 && links_request.code == 200
        flash.now[:success] = "Created #{document.title}"
        redirect_to documents_path(current_format.document_type)
      else
        flash.now[:danger] = "There was an error publishing #{document.title}. Please try again later."
        render :new, locals: { document: document }
      end
    else
      document_errors = document.errors.messages
      errors = content_tag(:p,
        %Q{
          There #{document_errors.length > 1 ? 'were' : 'was' } the following
          #{document_errors.length > 1 ? 'errors' : 'error' } with your
          #{current_format.title.singularize}:
        }
      )
      errors += content_tag :ul do
        document.errors.full_messages.map { |e| content_tag(:li, e) }.join('').html_safe
      end

      flash.now[:danger] = errors
      render :new, locals: { document: document }, status: 422
    end
  end

  def show
    @document = current_format.klass.from_publishing_api(publishing_api.get_content(params[:id]).to_ostruct)
  end
private

  def document_type
    params[:document_type]
  end

  def document_klass
    current_format.klass
  end

  def filtered_params(params_of_document)
    filter_blank_multi_selects(params_of_document).with_indifferent_access
  end

  # See http://stackoverflow.com/questions/8929230/why-is-the-first-element-always-blank-in-my-rails-multi-select
  def filter_blank_multi_selects(values)
    values.reduce({}) { |filtered_params, (key, value)|
      filtered_value = value.is_a?(Array) ? value.reject(&:blank?) : value
      filtered_params.merge(key => filtered_value)
    }
  end

  def publishing_api
    @publishing_api ||= SpecialistPublisher.services(:publishing_api)
  end

end
