class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless parsable_date?(value)
      record.errors.add(attribute, error_message)
    end
  end

private
  def parsable_date?(date_string)
    date_string =~ iso8601_regex && Date.parse(date_string)
  rescue ArgumentError
    false
  end

  def iso8601_regex
    /\A[0-9]{4}\-[0-9]{2}\-[0-9]{2}\z/
  end

  def error_message
    options[:message] || "should be formatted YYYY-MM-DD"
  end
end
