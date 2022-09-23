class OpenBeforeClosedValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(options[:opened_date], error_message) unless before_closed?(record)
  end

private

  def before_closed?(record)
    opened = record.try(options[:opened_date])
    closed = record.try(options[:closed_date])

    opened.blank? || closed.blank? || opened <= closed
  end

  def error_message
    options[:message] || "must be before closed date"
  end
end
