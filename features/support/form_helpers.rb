module FormHelpers
  def fill_in_fields(fields)
    fields.each do |field, text|
      fill_in field.to_s.humanize, with: text
    end
  end
end
