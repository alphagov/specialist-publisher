module OrganisationsHelper
  def organisations_options
    Organisation.all.map { |o| [o.title, o.content_id] }
  end

  def primary_publishing_organisation_options(form)
    return {} if form.object.primary_publishing_organisation.present?

    { selected: current_user.organisation_content_id }
  end
end
