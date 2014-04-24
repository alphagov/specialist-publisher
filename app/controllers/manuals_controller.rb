class ManualsController < ApplicationController
  def index
  end

  def new
    render_with(manual: new_manual)
  end

private
  def new_manual
    ManualForm.new
  end
end
