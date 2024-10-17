class AdminController < ApplicationController
  layout "design_system"

  before_action :check_authorisation, if: :document_type_slug

  def index_of_admin_forms; end

  def edit_metadata; end

  def edit_facets; end

  def save_metadata
    @submitted_params = params.permit(
      :name,
      :description,
      :organisations,
      :editing_organisations,
      :related,
      :base_path,
      :content_id,
      "filter.format".to_sym,
      :format_name,
      :document_title,
      :document_noun,
    ).to_unsafe_h
    %i[organisations editing_organisations related].each do |str_that_should_be_arr|
      @submitted_params[str_that_should_be_arr] = @submitted_params[str_that_should_be_arr].split("\r\n")
      if @submitted_params[str_that_should_be_arr].empty?
        @submitted_params.delete(str_that_should_be_arr)
      end
    end
    @submitted_params["filter"] = { "format": @submitted_params["filter.format".to_sym] }
    @submitted_params.delete("filter.format".to_sym)

    @original_schema = current_format.finder_schema.schema
    @proposed_schema = @original_schema.merge(@submitted_params)
    render :temporary_output
  end

  def save_facets
    @submitted_params = params.except(:authenticity_token, :action, :controller, :document_type_slug).to_unsafe_h
    # hashes come through as e.g. `facets: { "0": { "name": "Category"... }}`,
    # we need to convert to array e.g. `facets: [ { "name", "Category"... } ]`
    @submitted_params["facets"] = @submitted_params["facets"].keys.map(&:to_i).sort.map do |i|
      @submitted_params["facets"][i.to_s]
    end
    @submitted_params["facets"].each_with_index do |hash, i|
      hash.each do |key, value|
        # delete empty values
        if value == ""
          @submitted_params["facets"][i].delete(key)
        # cast booleans
        elsif %w[true false].include?(value)
          @submitted_params["facets"][i][key] = value == "true"
        end
      end
    end

    @original_schema = current_format.finder_schema.schema
    @proposed_schema = @original_schema.merge(@submitted_params)
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
end
