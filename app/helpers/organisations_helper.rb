module OrganisationsHelper
  def organisations_options
    Organisation.all.map { |o| [o.title, o.content_id] }
  end

  def selected_organisation_or_current(organisation)
    (organisation.presence || current_user.organisation_content_id)
  end
end
