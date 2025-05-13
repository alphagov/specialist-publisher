module OrganisationsHelper
  def all_organisations
    @all_organisations ||= Organisation.all
  end

  def organisations_options
    all_organisations.map { |o| [o.title, o.content_id] }.sort_by { |title, _id| title.downcase.strip }
  end

  def organisations_options_with_all
    [["All organisations", "all"]].concat(organisations_options)
  end

  def organisation_options_for_design_system(selected_organisation_content_id)
    all_organisations.sort_by { |org| org.title.downcase.strip }.map do |organisation|
      {
        text: organisation.title,
        value: organisation.content_id,
        selected: organisation.content_id == selected_organisation_content_id,
      }
    end
  end

  def selected_organisation_or_current(organisation)
    organisation.presence || current_user.organisation_content_id
  end

  def organisation_name(content_id)
    all_organisations.select { |o| o.content_id == content_id }.first&.title
  end
end
