class ManualsController < ApplicationController
  before_action :check_authorisation

  def check_authorisation
    authorize :manual
  end

  def index
    @manuals = policy_scope(Manual)
  end

  def show
    begin
      @manual = Manual.find(content_id: params[:content_id])
    rescue Manual::RecordNotFound => e
      flash[:danger] = "Manual not found"
      redirect_to manuals_path

      Airbrake.notify(e)
    end
  end

  def new
    @manual = Manual.new
  end

  def create
    @manual = Manual.new(manual_params)
    @manual.organisation_content_ids = [current_user.organisation_content_id]

    if @manual.save
      flash[:success] = "Created #{@manual.title}"
      redirect_to manual_path(@manual.content_id)
    else
      flash.now[:danger] = "There was an error creating #{@manual.title}. Please try again later."
      render :new
    end
  end

  def edit
    @manual = Manual.find(content_id: params[:content_id])
  end

  def update
    @manual = Manual.find(content_id: params[:content_id])

    if @manual.update_attributes(manual_params)
      flash[:success] = "#{@manual.title} has been updated"
      redirect_to manual_path(@manual.content_id)
    else
      flash.now[:danger] = "There was an error updating #{@manual.title}. Please try again later."
      render :edit
    end
  end

private

  def manual_params
    params.require(:manual).permit(:title, :summary, :body)
  end
end
