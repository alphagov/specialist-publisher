require 'gds_api/publishing_api_v2'

class DocumentsController <  ApplicationController
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  before_action :fetch_document, only: [:edit, :show, :publish, :update]

  def index
    unless params[:document_type]
      redirect_to "/#{document_types.keys.first}"
      return
    end

    response = publishing_api.get_content_items(
      content_format: current_format.format_name,
      fields: [
        :base_path,
        :content_id,
        :title,
        :public_updated_at,
        :details,
        :description,
      ]
    ).to_ostruct

    @documents = response.map { |payload| document_klass.from_publishing_api(payload) }
    @documents.sort!{ |a, b| a.public_updated_at <=> b.public_updated_at }.reverse!
  end

  def new
    @document = document_klass.new
  end

  def create
    @document = document_klass.new(
      filtered_params(params[current_format.format_name])
    )

    if @document.valid?
      if save_document
        flash[:success] = "Created #{@document.title}"
        redirect_to documents_path(current_format.document_type)
      else
        flash.now[:danger] = "There was an error creating #{@document.title}. Please try again later."
        render :new
      end
    else
      flash.now[:danger] = document_error_messages
      render :new, status: 422
    end
  end

  def show; end

  def edit; end

  def update
    new_params = filtered_params(params[current_format.format_name])

    new_params.each do |k, v|
      @document.public_send(:"#{k}=", v)
    end

    @document.public_updated_at = Time.zone.now.to_s

    if @document.valid?
      if save_document
        flash[:success] = "Updated #{@document.title}"
        redirect_to documents_path(current_format.document_type)
      else
        flash.now[:danger] = "There was an error updating #{@document.title}. Please try again later."
        render :edit
      end
    else
      flash.now[:danger] = document_error_messages
      render :edit, status: 422
    end
  end

  def publish
    indexable_document = SearchPresenter.new(@document)

    begin
      publish_request = publishing_api.publish(params[:content_id], "major")
      rummager_request = rummager.add_document(
        @document.format,
        @document.base_path,
        indexable_document.to_json,
      )
    rescue GdsApi::HTTPErrorResponse => e
      Airbrake.notify(e)
    end

    if publish_request.code == 200 && rummager_request.code == 200
      flash[:success] = "Published #{@document.title}"
      redirect_to documents_path(current_format.document_type)
    else
      flash[:danger] = "There was an error publishing #{@document.title}. Please try again later."
      redirect_to document_path(current_format.document_type, params[:content_id])
    end
  end

private

  def document_type
    params[:document_type]
  end

  def document_klass
    current_format.klass
  end

  def document_error_messages
    document_errors = @document.errors.messages
    errors = content_tag(:p,
      %Q{
        There #{document_errors.length > 1 ? 'were' : 'was' } the following
        #{document_errors.length > 1 ? 'errors' : 'error' } with your
        #{current_format.title.singularize}:
      }
    )
    errors += content_tag :ul do
      @document.errors.full_messages.map { |e| content_tag(:li, e) }.join('').html_safe
    end
  end

  def fetch_document
    @document = document_klass.from_publishing_api(publishing_api.get_content(params[:content_id]).to_ostruct)
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

  def save_document
    presented_document = DocumentPresenter.new(@document)
    presented_links = DocumentLinksPresenter.new(@document)

    begin
      item_request = publishing_api.put_content(@document.content_id, presented_document.to_json)
      links_request = publishing_api.put_links(@document.content_id, presented_links.to_json)

      item_request.code == 200 && links_request.code == 200
    rescue GdsApi::HTTPErrorResponse => e
      Airbrake.notify(e)

      false
    end
  end

  def publishing_api
    @publishing_api ||= SpecialistPublisher.services(:publishing_api)
  end

  def rummager
    @rummager ||= SpecialistPublisher.services(:rummager)
  end

end
