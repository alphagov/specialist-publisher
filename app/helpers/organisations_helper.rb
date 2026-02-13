module OrganisationsHelper
  def organisation_single_select_options(selected_organisation_content_id, has_all_option: false)
    organisations = all_organisations
      .sort_by { |org| org.title.downcase.strip }
      .map do |organisation|
        {
          text: organisation.title,
          value: organisation.content_id,
          selected: organisation.content_id == selected_organisation_content_id,
        }
    end

    has_all_option ? organisations.prepend({ text: "All organisations", value: "all", selected: false }) : organisations
  end

  def selected_organisation_or_current(organisation)
    organisation.presence || current_user.organisation_content_id
  end

  def organisation_name(content_id)
    all_organisations.select { |o| o.content_id == content_id }.first&.title
  end

private

  def all_organisations
    @all_organisations ||= Organisation.all
  end
end
