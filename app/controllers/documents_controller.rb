require 'gds_api/publishing_api_v2'

class DocumentsController < ApplicationController
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  before_action :fetch_document, only: [:edit, :show, :publish, :update]
  before_action :check_authorisation, if: :document_type

  def check_authorisation
    if current_format
      authorize current_format
    else
      flash[:danger] = "That format doesn't exist. If you feel you've reached this in error, contact your SPOC."
      redirect_to manuals_path
    end
  end

  def index
    page = filtered_page_param(params[:page])
    per_page = filtered_per_page_param(params[:per_page])
    @query = params[:query]
    @response = current_format.all(page, per_page, q: @query)
    @paged_documents = PaginationPresenter.new(@response, per_page)
  end

  def new
    @document = current_format.new
  end

  def create
    @document = current_format.new(
      filtered_params(params[current_format.format_name])
    )

    if @document.valid?
      if @document.save!
        flash[:success] = "Created #{@document.title}"
        redirect_to document_path(current_format.document_type, @document.content_id)
      else
        flash.now[:danger] = "There was an error creating #{@document.title}. Please try again later."
        render :new
      end
    else
      flash.now[:errors] = document_error_messages
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

    if @document.valid?
      if @document.save!
        flash[:success] = "Updated #{@document.title}"
        redirect_to document_path(current_format.document_type, @document.content_id)
      else
        flash.now[:danger] = "There was an error updating #{@document.title}. Please try again later."
        render :edit
      end
    else
      flash.now[:errors] = document_error_messages
      render :edit, status: 422
    end
  end

  def publish
    if @document.publish!
      flash[:success] = "Published #{@document.title}"
    else
      flash[:danger] = "There was an error publishing #{@document.title}. Please try again later."
    end
    redirect_to document_path(current_format.document_type, params[:content_id])
  end

private

  def document_error_messages
    @document.errors.messages
    heading = content_tag(
      :h4,
      %{
        Please fix the following errors
      }
    )
    errors = content_tag :ul, class: "list-unstyled remove-bottom-margin" do
      @document.errors.full_messages.map { |e| content_tag(:li, e) }.join('').html_safe
    end

    heading + errors
  end

  def fetch_document
    @document = current_format.find(params[:content_id])
  rescue Document::RecordNotFound => e
    flash[:danger] = "Document not found"
    redirect_to documents_path(document_type: document_type)

    Airbrake.notify(e)
  end

  def filtered_page_param(page)
    page.to_i.to_s == page ? page : 1
  end

  def filtered_per_page_param(per_page)
    per_page.to_i.to_s == per_page ? per_page : 50
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
    @publishing_api ||= Services.publishing_api
  end

  def rummager
    @rummager ||= Services.rummager
  end
end
