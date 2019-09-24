require "gds_api/publishing_api_v2"

class DocumentsController < ApplicationController
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  before_action :fetch_document, except: %i[index new create]
  before_action :check_authorisation, if: :document_type_slug

  def index
    page = filtered_page_param(params[:page])
    per_page = filtered_per_page_param(params[:per_page])
    @query = params[:query]
    @response = current_format.all(page, per_page, query: @query)
    @paged_documents = PaginationPresenter.new(@response, per_page)
  end

  def new
    @document = current_format.new
  end

  def create
    @document = current_format.new(filtered_params)

    if @document.save
      flash[:success] = "Created #{@document.title}"
      redirect_to document_path(current_format.slug, @document.content_id)
    elsif @document.errors.any?
      flash.now[:errors] = document_error_messages
      render :new, status: 422
    else
      flash.now[:danger] = unknown_error_message
      render :new
    end
  end

  def show
    if @document.content_item_blocking_publish?
      flash[:danger] = "Warning: This document's URL is already used on GOV.UK. You can't publish it until you change the title."
    end
  end

  def edit; end

  def update
    @document.set_attributes(filtered_params)

    if @document.valid?
      if @document.save
        flash[:success] = "Updated #{@document.title}"
        redirect_to document_path(current_format.slug, @document.content_id)
      else
        flash.now[:danger] = unknown_error_message
        render :edit
      end
    else
      flash.now[:errors] = document_error_messages
      render :edit, status: 422
    end
  end

  def publish
    if @document.publish
      flash[:success] = "Published #{@document.title}"
    else
      flash[:danger] = unknown_error_message
    end
    redirect_to document_path(current_format.slug, params[:content_id])
  end

  def unpublish
    if @document.unpublish(params[:alternative_path])
      flash[:success] = "Unpublished #{@document.title}"
    else
      flash[:danger] = unknown_error_message
    end
  rescue DocumentUnpublisher::AlternativeContentNotFound => e
    flash[:danger] = e.message
  ensure
    redirect_to document_path(current_format.slug, params[:content_id])
  end

  def discard
    if @document.discard
      flash[:success] = "Discarded draft of #{@document.title}"
    else
      flash[:danger] = unknown_error_message
    end
    redirect_to documents_path(current_format.slug)
  end

private

  def check_authorisation
    if current_format
      authorize current_format
    else
      flash[:danger] = "That format doesn't exist. If you feel you've reached this in error, contact your SPOC."
      redirect_to root_path
    end
  end

  def unknown_error_message
    support_url = Plek.new.external_url_for("support") + "/technical_fault_report/new"

    "Something has gone wrong. Please try again and see if it works. <a href='#{support_url}'>Let us know</a>
    if the problem happens again and a developer will look into it.".html_safe
  end

  def document_error_messages
    @document.errors.messages
    heading = content_tag(
      :h4,
      %{
        Please fix the following errors
      },
    )
    errors = content_tag :ul, class: "list-unstyled remove-bottom-margin" do
      list_items = @document.errors.full_messages.map do |message|
        content_tag(:li, message.html_safe)
      end
      list_items.join.html_safe
    end

    heading + errors
  end

  def fetch_document
    @document = current_format.find(params[:content_id])
  rescue DocumentFinder::RecordNotFound => e
    flash[:danger] = "Document not found"
    redirect_to documents_path(document_type_slug: document_type_slug)

    GovukError.notify(e)
  end

  def filtered_page_param(page)
    page.to_i.to_s == page ? page : 1
  end

  def filtered_per_page_param(per_page)
    per_page.to_i.to_s == per_page ? per_page : 50
  end

  def permitted_params
    params[current_format.document_type].permit!
  end

  def filtered_params
    filter_blank_multi_selects(permitted_params.to_h).with_indifferent_access
  end

  # See http://stackoverflow.com/questions/8929230/why-is-the-first-element-always-blank-in-my-rails-multi-select
  def filter_blank_multi_selects(values)
    values.reduce({}) { |filtered_params, (key, value)|
      filtered_value = value.is_a?(Array) ? value.reject(&:blank?) : value
      filtered_params.merge(key => filtered_value)
    }
  end
end
