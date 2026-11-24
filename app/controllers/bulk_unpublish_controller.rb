class BulkUnpublishController < ApplicationController
  before_action :enforce_gds_editor!
  before_action :authorize_chosen_format, only: %i[preview unpublish]

  def index
    skip_authorization
  end

  def preview
    unpublisher = validated_unpublisher
    @errors = unpublisher.errors

    return render :index if @errors.any?

    @changes = unpublisher.summarise_changes
  end

  def unpublish
    unpublisher = validated_unpublisher
    @errors = unpublisher.errors

    return render :index if @errors.any?

    BulkUnpublishWorker.perform_async(current_format.admin_slug, current_user.id.to_s, csv_input)

    flash[:success] = "The documents are being unpublished"
    redirect_to bulk_unpublish_path
  end

private

  def validated_unpublisher
    BulkDocumentUnpublisher.new(current_format, csv_input).tap(&:validate)
  end

  def csv_input
    params[:csv_input]
  end

  def enforce_gds_editor!
    return if current_user.gds_editor?

    flash[:danger] = "You aren't permitted to bulk unpublish documents. Please contact your main GDS contact if you need access."
    redirect_to root_path
  end

  def authorize_chosen_format
    return authorize(current_format, :unpublish?) if current_format

    skip_authorization
    @errors = ["Select a document type"]
    render :index
  end
end
