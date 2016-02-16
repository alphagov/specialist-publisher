class ManualSectionsController < ApplicationController
  def show
    @section = Section.find(content_id: params[:content_id])
  end

  def edit

  end
end
