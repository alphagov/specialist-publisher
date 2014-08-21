module DateTimeHelper

  def time_with_local_zone(time)
    ActiveSupport::TimeZone.new("London").at(time)
  end

  def nice_time_format(time)
    content_tag :time, datetime: time.iso8601 do
      time.strftime("%l:%M%P on %-d %B %Y")
    end
  end

end
