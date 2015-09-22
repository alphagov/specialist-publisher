module FormHelpers
  def fill_in_fields(names_and_values)
    names_and_values.each do |field_name, value|
      fill_in_field(field_name, value)
    end
  end

  def fill_in_field(field_name, value)
    label_text = field_name.to_s.humanize

    if page.first(:select, label_text)
      select value, from: label_text
    else
      fill_in label_text, with: value
    end
  end
end
RSpec.configuration.include FormHelpers, type: :feature
