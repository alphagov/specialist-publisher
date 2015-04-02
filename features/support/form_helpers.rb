module FormHelpers
  def fill_in_fields(field_names)
    field_names.each do |field_name, value|
      human_field_name = field_name.to_s.humanize
      tag_name = page.find_field(field_name.to_s.humanize).tag_name

      case tag_name
      when "select"
        select value, from: human_field_name
      else
        fill_in human_field_name, with: value
      end
    end
  end
end
