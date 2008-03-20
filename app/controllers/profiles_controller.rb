class ProfilesController < ApplicationController
  before_filter :login_required, :except => :show
  before_filter :fetch_profile, :except => :show

  verify :method => :post,    :only => :create
  verify :method => :put,     :only => :update
  verify :method => :delete,  :only => :destroy

  def show
    @person = params[:person_id] ?  User.find( params[:person_id] ) : current_user
    access_denied unless @profile = @person.profile_for(current_user)
  end

  def edit
  end

  def new
  end

  def create
    @profile = Profile.new params[:profile]
    if @profile.save
      redirect_to :controller => 'profiles', :action => 'show'
    else
      render :action => 'new'
    end
  end
  
  def update
    if @profile.update_attributes params[:profile]
      respond_to do |format|
        format.html do
          flash[:notice] = "Save your profile changes"
          redirect_to :controller => 'profiles', :action => 'show'
        end
        format.xml  { head:ok }
        format.json { head:ok }
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    @profile.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = "Deleted profile record"
        redirect_to :controller => 'me', :action => 'index'
      end
      format.xml  { head:ok }
      format.json { head:ok }
    end
  end

  private
    def fetch_profile
      @profile = current_user.private_profile || 
                  Profile.new( :entity => current_user, :friend => true ) 
    end

end
