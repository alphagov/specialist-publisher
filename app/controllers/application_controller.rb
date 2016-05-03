class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include GDS::SSO::ControllerMethods
  include Pundit

  before_filter :require_signin_permission!

  helper_method :current_format
  helper_method :formats_user_can_access

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

private

  def user_not_authorized
    flash[:danger] = "You aren't permitted to access #{current_format.title.pluralize}. If you feel you've reached this in error, contact your SPOC."
    redirect_to manuals_path
  end


  def document_type
    params[:document_type]
  end

  def current_format
    document_types.fetch(params.fetch(:document_type, nil), nil)
  end

  def formats_user_can_access
    document_types.select { |_, v| policy(v.klass).index? }
  end

  # This Struct is for the document_types method below
  FormatStruct = Struct.new(:klass, :document_type, :format_name, :title, :organisations)

  def document_types
    # For each format that follows the standard naming convention, this
    # method takes the model class and generates a FormatStructure.
    #
    # eg GdsReport will become this:
    #
    # {
    #   "gds-reports" => FormatStruct.new(
    #     klass: GdsReports, # This is the class name of the model
    #     document_type: "gds-reports", # This is internally used for building urls
    #     format_name: "gds_report", # This is used for fetching the params of the format
    #     title: "GDS Report", # Rendered as the format name to the User, taken from GdsReport.title
    #     organisations: ["a-content-id"], # Content IDs for the Orgs fetched from the schema
    #   )
    # }

    document_classes = [
      AaibReport,
      CmaCase,
      CountrysideStewardshipGrant,
      DrugSafetyUpdate,
      EmploymentAppealTribunalDecision,
      EsiFund,
      EmploymentTribunalDecision,
      MaibReport,
      MedicalSafetyAlert,
      RaibReport,
      TaxTribunalDecision,
      VehicleRecallsAndFaultsAlert,
    ]

    document_classes.map { |document_class|
      title = document_class.title
      {
        title.downcase.parameterize.pluralize => FormatStruct.new(
          document_class,
          title.downcase.parameterize.pluralize,
          document_class.to_s.underscore,
          title,
          document_class.organisations,
        )
      }
    }.reduce({}, :merge)
  end

  def document_klass
    current_format.klass
  end
end
