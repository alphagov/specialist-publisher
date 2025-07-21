module DateHelper
  # Constructs a date string, attempting to produce
  # the format YYYY-MM-dd. Expects the Rails convention
  # for multiple parameter date fragments.
  def date_param_value(params, key)
    k = clean_key(key)
    attrs = params.symbolize_keys
    if attrs.key?(:"#{k}(1i)")
      format_date = [
        attrs.fetch(:"#{k}(1i)"),
        attrs.fetch(:"#{k}(2i)"),
        attrs.fetch(:"#{k}(3i)"),
      ]
      format_date.delete_if(&:empty?)
      format_date.map { |d| zero_pad(d) }.join("-")
    end
  end

  def clean_key(key)
    key.to_s.gsub(/\(\di\)$/, "")
  end

private

  def zero_pad(value)
    return value unless value =~ /^\d$/

    sprintf("%02d", value)
  end
end
