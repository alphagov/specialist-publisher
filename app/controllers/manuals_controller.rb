class ManualsController <  ApplicationController

  def index
    if current_user.gds_editor?
      @manuals = Manual.all
    else
      @manuals = Manual.where(organisation_content_id: current_user.organisation_content_id)
    end
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

end
