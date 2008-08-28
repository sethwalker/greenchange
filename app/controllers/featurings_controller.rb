# Feature pages by issue
class FeaturingsController < ApplicationController
  before_filter :superuser_required
  before_filter :target_and_issue_required, :only => :create

  make_resourceful do
    actions :create, :destroy
    response_for :create do
      flash[:notice] = "#{@featured.display_name} is now featured in #{@issue.display_name}"
      redirect_to issue_path( @issue )
    end
    response_for :destroy do
      flash[:notice] = "#{@featuring.page.display_name} is no longer featured in #{@issue.display_name}"
      redirect_to issue_path( @issue )
    end
  end

  def current_object
    return super if params[:id]
    @featuring ||= Featuring.new :issue => @issue, :page => @featured
  end

  def target_and_issue_required
    @featured = Page.find( params[:page_id] )
    raise ActiveRecord::RecordNotFound unless @featured && @issue
  end
end
