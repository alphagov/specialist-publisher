class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    date = Date.strptime(value, "%Y-%m-%d")
    unless date.year.between?(1000, 9999)
      record.errors.add(attribute, "must be between year 1000 and 9999")
    end
  rescue ArgumentError, RangeError
    record.errors.add(attribute, "is not a valid date")
  end
end
