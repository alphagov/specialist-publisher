require "delegate"
require "validators/date_validator"
require "validators/safe_html_validator"

class VehicleRecallsAndFaultsAlertValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true

  validates :alert_issue_date, allow_blank: true, date: true
  validates :build_start_date, allow_blank: true, date: true
  validates :build_end_date, allow_blank: true, date: true

  validate :build_dates

private

  def build_dates
    return unless build_start_date.present? && build_end_date.present?
    errors.add(:build_start_date, "must be before build end date") if build_start_date > build_end_date
  end
end
