class OpenBeforeClosedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    record.errors.add(attribute, error_message) unless before_closed?(record)
  end

private

  def before_closed?(record)
    opened = record.try(:opened_date) || record.try(:foo_project_opened_date)
    closed = record.try(:closed_date) || record.try(:foo_project_closed_date)

    opened.blank? || closed.blank? || opened <= closed
  end

  def error_message
    options[:message] || "must be before closed date"
  end
end
