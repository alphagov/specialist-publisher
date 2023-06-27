class LicenceIdentifierUniqueValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    existing_licence_identifiers = []

    record.class.find_each do |licence|
      next if record.content_id == licence.content_id

      existing_licence_identifiers << licence.licence_transaction_licence_identifier
    end

    if existing_licence_identifiers.include?(value)
      record.errors.add(attribute, :taken)
    end
  end
end
