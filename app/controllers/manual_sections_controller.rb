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

  def new
    @section = Section.new(manual_content_id: params["manual_content_id"])
  end

  def create
    section_data = params["section"]
    section_data["manual_content_id"] = params["manual_content_id"]

    @section = Section.new(section_data)

    if @section.save
      flash[:success] = "Created #{@section.title}"
      redirect_to manual_path(@section.manual.content_id)
    else
      flash.now[:danger] = "There was an error creating #{@section.title}. Please try again later."
      render :new
    end
  end

  def edit

  end
end
