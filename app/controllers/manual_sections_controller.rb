class ManualSectionsController < ApplicationController
  def show
    @section = Section.find(
      content_id: params[:content_id],
      manual_content_id: params[:manual_content_id]
    )
  rescue Section::RecordNotFound => e
    flash[:danger] = e.message

    redirect_to manuals_path

    Airbrake.notify(e)
  end

  def edit

  end
end
