require 'specialist_publisher_wiring'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  SpecialistPublisherWiring.inject_into(self)
end
