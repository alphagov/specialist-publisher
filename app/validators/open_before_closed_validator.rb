class OpenBeforeClosedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    record.errors.add(attribute, error_message) unless before_closed?(record)
  end

private

  def before_closed?(record)
    record.opened_date <= record.closed_date || record.closed_date.blank?
  end

  def error_message
    options[:message] || "must be before closed date"
  end
end
