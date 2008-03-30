class IssuesController < ApplicationController
  before_filter { raise PermissionDenied unless action_name =~ /show|index/ }

  def show
  end

  def index
  end


end
