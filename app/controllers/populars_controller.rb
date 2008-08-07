class PopularsController < ApplicationController

  def show
    @pages = Page.popular.allowed(current_user).find :all
  end

end

