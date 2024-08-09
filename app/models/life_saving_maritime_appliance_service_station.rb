class LifeSavingMaritimeApplianceServiceStation < Document
  validates :life_saving_maritime_appliance_service_station_regions, presence: true
  validates :life_saving_maritime_appliance_manufacturer, presence: true

  def self.title
    "Life Saving Maritime Appliance Service Station"
  end
end
