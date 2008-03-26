class IssuesController < ApplicationController

  def show
    @issue = Issue.find_by_name params[:id].gsub '-', ' '
  end

  def index
    load_context
  end

end
