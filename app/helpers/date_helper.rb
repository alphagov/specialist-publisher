module DateHelper
  def date_value(measure, field)
    if /^\d{4}-\d{2}-\d{2}$/ =~ field
      sprintf('%02d', Date.strptime(field).public_send(measure))
    end
  end
end
