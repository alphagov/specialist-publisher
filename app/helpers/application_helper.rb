module ApplicationHelper
  def locale_codes
    I18n.t("language_names").keys
  end

  def map_locale_names
    locale_codes.index_by { |l| t("language_names.#{l}", locale: "en") }
  end
end
