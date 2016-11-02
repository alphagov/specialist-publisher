class VehicleRecallsAndFaultsAlert < Document
  validates :alert_issue_date, allow_blank: true, date: true
  validates :build_start_date, allow_blank: true, date: true
  validates :build_end_date, allow_blank: true, date: true

  validate :build_dates

  FORMAT_SPECIFIC_FIELDS = %i(
    fault_type
    faulty_item_type
    alert_issue_date
    manufacturer
    faulty_item_model
    serial_number
    build_start_date
    build_end_date
  ).freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Vehicle Recalls and Faults Alert"
  end

private

  def build_dates
    return unless build_start_date.present? && build_end_date.present?
    errors.add(:build_start_date, "must be before build end date") if build_start_date > build_end_date
  end
end
