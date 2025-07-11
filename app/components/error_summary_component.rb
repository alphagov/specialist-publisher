# frozen_string_literal: true

class ErrorSummaryComponent < ViewComponent::Base
  include ErrorsHelper

  attr_reader :object, :errors

  def initialize(object:, parent_class: nil)
    @object = object
    @parent_class = parent_class
    @errors = object.errors
  end

  def render?
    errors.present?
  end

private

  def title
    "There is a problem"
  end

  def humanized_class_name
    @humanized_class_name ||= object.try(:format_name) || object.class.name.demodulize.underscore.humanize.downcase
  end

  def error_items
    errors.map do |error|
      error_item = {
        text: get_text(object_type, error),
        data_attributes: {
          module: "ga4-auto-tracker",
          "ga4-auto": {
            event_name: "form_error",
            type: ga4_title,
            text: error.full_message.to_s.humanize,
            section: error.attribute.to_s.humanize,
            action: "error",
          }.to_json,
        },
      }

      error_item[:href] = "##{parent_class}_#{error.attribute.to_s.gsub('.', '_')}" unless error.attribute == :base
      error_item
    end
  end

  def parent_class
    @parent_class ||= object.class.to_s.underscore
  end

  def object_type
    object.class.try(:document_type)
  end

  def ga4_title
    "#{object.try(:new_record?) ? 'New' : 'Editing'} #{object.model_name.human.downcase.titleize}"
  end
end
