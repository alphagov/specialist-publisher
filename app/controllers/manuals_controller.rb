class ManualsController < ApplicationController
  def index
  end

  def show
    render_with(manual: current_manual)
  end

  def new
    render_with(manual: new_manual)
  end

  def create
    manual = new_manual
    manual.update(form_params)

    if store(manual)
      redirect_to manual_path(manual)
    else
      render(:new, locals: {manual: manual})
    end
  end

private
  def current_manual
    manual_repository.fetch(params[:id])
  end

  def new_manual
    ManualForm.new
  end

  def form_params
    params.fetch(:manual, {})
  end

  def store(manual)
    manual_repository.store(manual)
  end

  def manual_repository
    ManualRepository.new
  end
end
