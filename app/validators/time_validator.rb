class TimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    Time.strptime(value, "%H:%M")
  rescue ArgumentError, RangeError
    record.errors.add(attribute, "is not a valid time")
  end
end
