require 'gds_api/publishing_api_v2'

class DocumentsController < ApplicationController
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  before_action :fetch_document, only: [:edit, :show, :publish, :update, :withdraw]
  before_action :permitted?, if: :document_type

  def index
    if current_format
      @documents = document_klass.all

      @documents.sort! { |a, b| a.public_updated_at <=> b.public_updated_at }.reverse!
    else
      redirect_to manuals_path
    end
  end

  def new
    @document = document_klass.new
  end

  def create
    @document = document_klass.new(
      filtered_params(params[current_format.format_name])
    )

    if @document.valid?
      if @document.save!
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

    if @document.valid?
      if @document.save!
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
    if @document.publish!
      flash[:success] = "Published #{@document.title}"
      redirect_to documents_path(current_format.document_type)
    else
      flash[:danger] = "There was an error publishing #{@document.title}. Please try again later."
      redirect_to document_path(current_format.document_type, params[:content_id])
    end
  end

  def withdraw
    if @document.withdraw!
      flash[:success] = "Withdrawn #{@document.title}"
      redirect_to document_path(current_format.document_type, params[:content_id])
    else
      flash[:danger] = "There was an error withdrawing #{@document.title}. Please try again later."
      redirect_to document_path(current_format.document_type, params[:content_id])
    end
  end

private

  def document_error_messages
    document_errors = @document.errors.messages
    heading = content_tag(
      :p,
      %{
        There #{document_errors.length > 1 ? 'were' : 'was'} the following
        #{document_errors.length > 1 ? 'errors' : 'error'} with your
        #{current_format.title.singularize}:
      }
    )
    errors = content_tag :ul do
      @document.errors.full_messages.map { |e| content_tag(:li, e) }.join('').html_safe
    end

    heading + errors
  end

  def fetch_document
    @document = document_klass.find(params[:content_id])
  rescue Document::RecordNotFound => e
    flash[:danger] = "Document not found"
    redirect_to documents_path(document_type: document_type)

    Airbrake.notify(e)
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

  def rummager
    @rummager ||= SpecialistPublisher.services(:rummager)
  end

  def permitted?
    if formats_user_can_access.fetch(document_type, nil)
      true
    elsif current_format
      flash[:danger] = "You aren't permitted to access #{current_format.title.pluralize}. If you feel you've reached this in error, contact your SPOC."
      redirect_to manuals_path
    else
      flash[:danger] = "That format doesn't exist. If you feel you've reached this in error, contact your SPOC."
      redirect_to manuals_path
    end
  end
end
