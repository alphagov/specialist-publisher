class LinkOrIdentifierValidator < ActiveModel::Validator
  def validate(record)
    if both_link_and_identifier_exist?(record) || both_link_and_identifier_missing?(record)
      record.errors.add(:base, :link_and_identifier_exists)

      return
    end

    if will_continue_on_exists_and_link_blank?(record)
      record.errors.add(:licence_transaction_continuation_link, :blank)
    end

    if will_continue_on_blank_and_link_exists?(record)
      record.errors.add(:licence_transaction_will_continue_on, :blank)
    end
  end

private

  def both_link_and_identifier_exist?(record)
    (record.licence_transaction_will_continue_on.present? || record.licence_transaction_continuation_link.present?) &&
      record.licence_transaction_licence_identifier.present?
  end

  def both_link_and_identifier_missing?(record)
    record.licence_transaction_will_continue_on.blank? && record.licence_transaction_continuation_link.blank? &&
      record.licence_transaction_licence_identifier.blank?
  end

  def will_continue_on_exists_and_link_blank?(record)
    record.licence_transaction_will_continue_on.present? && record.licence_transaction_continuation_link.blank?
  end

  def will_continue_on_blank_and_link_exists?(record)
    record.licence_transaction_will_continue_on.blank? && record.licence_transaction_continuation_link.present?
  end
end
