class ManualsController < ApplicationController
  def index
    all_manuals = services.list_manuals(self).call

    render(:index, locals: { manuals: all_manuals })
  end

  def show
    manual = services.show_manual(self).call

    render(:show, locals: { manual: manual })
  end

  def new
    # manual = services.new_manual(self).call
    manual = nil

    render(:new, locals: { manual: manual_form(manual) })
  end

  def create
    manual = services.create_manual(self).call
    manual = manual_form(manual)

    if manual.valid?
      redirect_to(manual_path(manual))
    else
      render(:new, locals: {
        manual: manual,
      })
    end
  end

  def edit
    manual = services.show_manual(self).call

    render(:edit, locals: { manual: manual_form(manual) })
  end

  def update
    manual = services.update_manual(self).call
    manual = manual_form(manual)

    if manual.valid?
      redirect_to(manual_path(manual))
    else
      render(:edit, locals: {
        manual: manual,
      })
    end
  end

  def publish
    manual = services.publish_manual(self).call

    redirect_to(manual_path(manual))
  end

private

  def manual_form(manual)
    ManualForm.new(manual)
  end
end
