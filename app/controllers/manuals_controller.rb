class ManualsController < ApplicationController
  def index
    all_manuals = services.list(self).call

    render(:index, locals: { manuals: all_manuals })
  end

  def show
    manual = services.show(manual_id).call

    render(:show, locals: { manual: manual })
  end

  def new
    manual = services.new(self).call

    render(:new, locals: { manual: manual_form(manual) })
  end

  def create
    manual = services.create(manual_params).call
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
    manual = services.show(manual_id).call

    render(:edit, locals: { manual: manual_form(manual) })
  end

  def update
    manual = services.update(manual_id, manual_params).call
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
    manual = services.queue_publish(manual_id).call

    redirect_to(
      manual_path(manual),
      flash: { notice: "Published #{manual.title}" },
    )
  end

private
  def manual_id
    params.fetch("id")
  end

  def manual_params
    params
      .fetch("manual")
      .slice(*valid_params)
      .merge(
        organisation_slug: current_organisation_slug,
      )
      .symbolize_keys
  end

  def valid_params
    %i(
      title
      summary
    )
  end

  def manual_form(manual)
    ManualViewAdapter.new(manual)
  end

  def services
    @services ||= OrganisationalManualServiceRegistry.new(
      organisation_slug: current_organisation_slug,
    )
  end
end
