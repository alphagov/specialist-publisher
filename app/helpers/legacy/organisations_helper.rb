module Legacy::OrganisationsHelper
  def organisations_options_legacy
    all_organisations.map { |o| [o.title, o.content_id] }.sort_by { |title, _id| title.downcase.strip }
  end

  def organisations_options_with_all_legacy
    [["All organisations", "all"]].concat(organisations_options_legacy)
  end

private

  def all_organisations
    @all_organisations ||= Organisation.all
  end
end
