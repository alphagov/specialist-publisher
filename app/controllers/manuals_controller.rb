class ManualsController < ApplicationController
  def index
    all_manuals = services.list(self).call

    render(:index, locals: { manuals: all_manuals })
  end

  def show
    manual = services.show(self).call

    render(:show, locals: { manual: manual })
  end

  def new
    manual = services.new(self).call

    render(:new, locals: { manual: manual_form(manual) })
  end

  def create
    manual = services.create(self).call
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
    manual = services.show(self).call

    render(:edit, locals: { manual: manual_form(manual) })
  end

  def update
    manual = services.update(self).call
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
    manual = services.show(self).call
    services.queue_publish(manual.id).call

    redirect_to(
      manual_path(manual),
      flash: { notice: "Published #{manual.title}" },
    )
  end

private
  def manual_form(manual)
    ManualViewAdapter.new(manual)
  end

  def services
    @services ||= OrganisationalManualServiceRegistry.new(
      organisation_slug: current_organisation_slug,
    )
  end
end
