module ApplicationHelper
  def facet_options(form, facet)
    form.object.facet_options(facet)
  end

  def locale_codes
    I18n.t('language_names').keys
  end

  def map_locale_names
    locale_codes.map { |l| [t("language_names.#{l}", locale: "en"), l] }.to_h
  end
end
