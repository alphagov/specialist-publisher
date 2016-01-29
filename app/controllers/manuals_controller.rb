class ManualsController <  ApplicationController

  def index
    @manuals = Manual.all
  end

end
