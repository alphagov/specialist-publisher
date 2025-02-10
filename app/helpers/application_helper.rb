module ApplicationHelper
  def options_for(form, facet_name)
    form.object.allowed_values(facet_name).map do |value|
      [
        value.fetch("label", ""),
        value.fetch("value", ""),
      ]
    end
  end

  def locale_codes
    I18n.t("language_names").keys
  end

  def map_locale_names
    locale_codes.index_by { |l| t("language_names.#{l}", locale: "en") }
  end
end
