class SafeHtmlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless safe_html?(value)
      record.errors.add(attribute, error_message)
    end
  end

private
  def safe_html?(html_string)
    Govspeak::HtmlValidator.new(html_string).valid?
  end

  def error_message
    options[:message] || "cannot include invalid HTML or JavaScript"
  end
end
