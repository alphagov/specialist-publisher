class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Date.parse(value)
    Date.strptime(value, '%Y-%m-%d')
  rescue ArgumentError, RangeError
    record.errors.add(attribute, "is not a valid date")
  end
end
