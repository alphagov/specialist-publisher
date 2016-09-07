class OpenBeforeClosedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    record.errors.add(attribute, error_message) unless before_closed?(record)
  end

private

  def before_closed?(record)
    opened = record.opened_date
    closed = record.closed_date

    opened.blank? || closed.blank? || opened <= closed
  end

  def error_message
    options[:message] || "must be before closed date"
  end
end
