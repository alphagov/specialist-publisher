class DocumentsController < ApplicationController
  include ActionView::Context
  include ActionView::Helpers::OutputSafetyHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include OrganisationsHelper

  before_action :fetch_document, except: %i[index new create]
  before_action :merge_nested_facet_fields, only: %i[edit new]
  before_action :check_authorisation, if: :document_type_slug

  def index
    page = filtered_page_param(params[:page])
    per_page = filtered_per_page_param(params[:per_page])
    @query = params[:query]
    if current_format.has_organisations?
      @organisation = selected_organisation_or_current(params[:organisation])
    end
    @response = current_format.all(page, per_page, query: @query, organisation: @organisation)
    @paged_documents = PaginationPresenter.new(@response, per_page)
    render :index
  end

  def new
    @document = current_format.new
  end

  def create
    @document = current_format.new(filtered_params)

    if @document.save
      flash[:success] = "Created #{@document.title}"
      redirect_to document_path(current_format.admin_slug, @document.content_id_and_locale)
    elsif @document.errors.any?
      re_render :new, status: :unprocessable_entity
    else
      re_render :new, flash_key: :danger, flash_message: unknown_error_message
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
        redirect_to document_path(current_format.admin_slug, @document.content_id_and_locale)
      else
        re_render :edit, flash_key: :danger, flash_message: unknown_error_message
      end
    else
      re_render :edit, status: :unprocessable_entity
    end
  end

  def confirm_publish; end

  def publish
    if @document.publish
      flash[:success] = "Published #{@document.title}"
    else
      flash[:danger] = unknown_error_message
    end
    redirect_to document_path(current_format.admin_slug, params[:content_id_and_locale])
  end

  def confirm_unpublish; end

  def unpublish
    if @document.unpublish(params[:alternative_path])
      flash[:success] = "Unpublished #{@document.title}"
    else
      flash[:danger] = unknown_error_message
    end

    redirect_to document_path(current_format.admin_slug, params[:content_id_and_locale])
  end

  def confirm_discard; end

  def discard
    if @document.discard
      flash[:success] = "The draft of '#{@document.title}' has been deleted"
    else
      flash[:danger] = unknown_error_message
    end
    redirect_to documents_path(current_format.admin_slug)
  end

  helper_method :computed_partial
  def computed_partial
    if lookup_context.exists?(@document.document_type.pluralize.to_s, %w[metadata_fields], true)
      "metadata_fields/#{@document.document_type.pluralize}"
    else
      "shared/specialist_document_form"
    end
  end

private

  def merge_nested_facet_fields
    return unless @document

    @document.finder_schema.nested_facets.pluck("key", "sub_facet_key").each do |facet_key, sub_facet_key|
      next unless @document.send(sub_facet_key)

      @document.assign_attributes(facet_key => (@document.send(facet_key) + @document.send(sub_facet_key)))
    end
  end

  def re_render(view, flash_key: nil, flash_message: nil, status: nil)
    merge_nested_facet_fields
    flash.now[flash_key] = flash_message
    render view, status:
  end

  def check_authorisation
    if current_format
      authorize current_format
    else
      flash[:danger] = "That format doesn't exist. If you feel you've reached this in error, please contact your main GDS contact."
      redirect_to root_path
    end
  end

  def unknown_error_message
    support_url = "#{Plek.external_url_for('support')}/technical_fault_report/new"

    safe_join(["Something has gone wrong. Please try again and see if it works. ", link_to("Let us know", support_url), " if the problem happens again and a developer will look into it."])
  end

  def content_id_param
    @content_id_param ||= params[:content_id_and_locale].split(":")[0]
  end

  def locale_param
    @locale_param ||= params[:content_id_and_locale].split(":")[1] || "en"
  end

  def fetch_document
    @document = current_format.find(content_id_param, locale_param)

    if params[:content_id_and_locale].split(":")[1] != @document.locale
      redirect_to(
        document_path(
          document_type_slug:,
          content_id_and_locale: @document.content_id_and_locale,
        ),
        status: :moved_permanently,
      )
    end
  rescue DocumentFinder::RecordNotFound => e
    flash[:danger] = "Document not found"
    redirect_to documents_path(document_type_slug:)

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
    values.reduce({}) do |filtered_params, (key, value)|
      filtered_value = value.is_a?(Array) ? value.reject(&:blank?) : value
      filtered_params.merge(key => filtered_value)
    end
  end
end
