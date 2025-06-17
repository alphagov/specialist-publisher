class FacetInputComponent::DateComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(document, document_type, facet_key, facet_name, params)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @error_items = errors_for(document.errors, facet_key)
    @params = params
  end

private

  def existing_year
    year_from_params = @params.dig(@document_type.to_s, "#{@facet_key}(1i)")
    return year_from_params if @params[@document_type.to_s].present?

    existing_date&.year
  end

  def existing_month
    month_from_params = @params.dig(@document_type.to_s, "#{@facet_key}(2i)")
    return month_from_params if @params[@document_type.to_s].present?

    existing_date&.month
  end

  def existing_day
    day_from_params = @params.dig(@document_type.to_s, "#{@facet_key}(3i)")
    return day_from_params if @params[@document_type.to_s].present?

    existing_date&.day
  end

  def existing_date
    @existing_date ||= Time.zone.parse(@document.send(@facet_key)).to_date if @document.send(@facet_key).present?
  end
end
