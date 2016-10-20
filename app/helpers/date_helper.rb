module DateHelper
  def date_value(measure, field)
    return if field.blank?
    year, month, day = field.split("-")
    { "year" => year, "month" => month, "day" => day }[measure]
  end
end
