module OrganisationsHelper
  def organisation_select_options(with:, selected_organisation: nil)
    prepopulated_value = case with
                         when :all
                           [
                             {
                               text: "All organisations",
                               value: "all",
                               selected: false,
                             },
                           ]
                         when :blank
                           [{}]
                         when :none
                           nil
                         end
    sorted_organisations = all_organisations.inject([]) { |options, organisation|
      options << {
        text: organisation.title,
        value: organisation.content_id,
        selected: organisation.content_id == selected_organisation,
      }
    }.sort_by { |option| option[:text].downcase.strip if option[:text].present? }

    prepopulated_value.nil? ? sorted_organisations : (prepopulated_value + sorted_organisations)
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
