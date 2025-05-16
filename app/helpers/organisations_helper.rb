module OrganisationsHelper
  def organisation_name(content_id)
    all_organisations.select { |o| o.content_id == content_id }.first&.title
  end

  def organisation_options_for_design_system(selected_organisation_content_id)
    [
      {
        text: "All organisations",
        value: "all",
        selected: false,
      },
    ] + all_organisations.sort_by { |org| org.title.downcase.strip }.map do |organisation|
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

  def organisations_select_options(selected_organisation_content_id = nil)
    all_organisations.inject([{}]) { |options, organisation|
      options << {
        text: organisation.title,
        value: organisation.content_id,
        selected: organisation.content_id == selected_organisation_content_id,
      }
    }.sort_by { |option| option[:text].downcase.strip if option[:text].present? }
  end

private

  def all_organisations
    @all_organisations ||= Organisation.all
  end
end
