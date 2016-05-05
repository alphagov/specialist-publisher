class ManualSectionsController < ApplicationController
  before_action :check_authorisation

  def check_authorisation
    authorize :manual
  end

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
    @section = Section.new(section_params.merge(manual_content_id: params[:manual_content_id]))

    if @section.save
      flash[:success] = "Created #{@section.title}"
      redirect_to manual_path(@section.manual.content_id)
    else
      flash.now[:danger] = "There was an error creating #{@section.title}. Please try again later."
      render :new
    end
  end

  def edit
    @section = Section.find(content_id: params[:content_id], manual_content_id: params[:manual_content_id])
  end

  def update
    @section = Section.find(content_id: params[:content_id], manual_content_id: params[:manual_content_id])

    if @section.update_attributes(section_params)
      flash[:success] = "#{@section.title} has been updated"
      redirect_to manual_section_path(@section.manual.content_id, @section.content_id)
    else
      flash.now[:danger] = "There was an error updating #{@section.title}. Please try again later."
      render :edit
    end
  end

private

  def section_params
    params.require(:section).permit(:title, :summary, :body)
  end
end
