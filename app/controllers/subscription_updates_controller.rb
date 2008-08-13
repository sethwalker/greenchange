class SubscriptionUpdatesController < ApplicationController
  before_filter :login_required
  def create
    current_user.subscriptions.each { |sub| sub.update! }
    if request.xhr?
      render :text => "Last Updated: Now", :status => :ok
    else
      respond_to do |format|
        format.html do 
          flash[:notice] = "Updated your subscriptions"
          redirect_to :back
        end
        format.json { head :ok }
        format.xml { head :ok }
      end
    end
  end
end
