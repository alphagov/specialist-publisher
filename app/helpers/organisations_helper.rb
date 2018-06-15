module OrganisationsHelper
  def organisations_options
    Organisation.all.map { |o| [o.title, o.content_id] }
  end
end
