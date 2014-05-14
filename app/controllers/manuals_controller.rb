class ManualsController < ApplicationController
  def index
    render_with(manuals: all_manuals)
  end

  def show
    render_with(manual: current_manual)
  end

  def new
    render_with(manual: manual_form)
  end

  def create
    save_manual
  end

  def edit
    render_with(manual: manual_form(current_manual))
  end

  def update
    save_manual(current_manual)
  end

private
  def all_manuals
    manual_repository.all
  end

  def current_manual
    manual_repository.fetch(params[:id])
  end

  def manual_form(manual = nil)
    ManualForm.new(manual)
  end

  def manual_params
    form_params.merge(organisation_slug: current_user.organisation_slug)
  end

  def form_params
    params.fetch(:manual, {})
  end

  def store(manual)
    manual_repository.store(manual)
  end

  def save_manual(manual = nil)
    manual = manual_form(manual)
    manual.update(manual_params)

    if manual.valid? && store(manual)
      redirect_to manual_path(manual)
    else
      if manual.persisted?
        render(:edit, locals: {manual: manual})
      else
        render(:new, locals: {manual: manual})
      end
    end
  end
end
