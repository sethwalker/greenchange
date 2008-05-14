class NetworksController < ApplicationController
  before_filter :login_required

  def show
    @pages = Page.in_network(current_user).allowed(current_user).find(:all, :order => "updated_at DESC", :limit => 40)
  end

  def connect
    @groups = Group.find(:all, :limit => 100)
    @people = User.enabled.find(:all, :limit => 100)
  end
end
