class AdminController < ApplicationController
  layout "design_system"

  before_action :check_authorisation, if: :document_type_slug

  def index_of_admin_forms; end

  def edit_metadata; end

  def edit_facets; end

  def save_metadata
    generate_shema
    render :temporary_output
  end

  def save_facets
    generate_shema
    render :temporary_output
  end

private

  def check_authorisation
    if current_format
      authorize current_format
    else
      flash[:danger] = "That format doesn't exist. If you feel you've reached this in error, please contact your main GDS contact."
      redirect_to root_path
    end
  end

  def generate_shema
    @submitted_params = params.except(:authenticity_token, :action, :controller, :document_type_slug).to_unsafe_h
    @submitted_params.each do |key, value|
      # hashes come through as e.g. `facets: { "0": { "name": "Category"... }}`,
      # we need to convert to array e.g. `facets: [ { "name", "Category"... } ]`
      if value.is_a?(Hash) && value.keys.include?("0")
        @submitted_params[key] = value.keys.map(&:to_i).sort.map { |i| @submitted_params[key][i.to_s] }
      end

      # booleans come through as strings, so need to cast those correctly
      # TODO: recursively apply throughout hash
      if %w[true false].include?(value)
        @submitted_params[key] = value == "true"
      end
    end
    @original_schema = current_format.finder_schema.schema
    @proposed_schema = @original_schema.merge(@submitted_params)
  end
end
