class ProfilesController < ApplicationController
  before_filter :login_required, :except => :show
  prepend_before_filter :fetch_profile, :except => :show

  #verify :method => :post,    :only => :create
  #verify :method => :put,     :only => :update
  #verify :method => :delete,  :only => :destroy

  helper :profile

  def show
    @person = params[:person_id] ?  User.find( params[:person_id] ) : current_user
    access_denied unless @person.is_a?(AuthenticatedUser) and @profile = @person.profile_for(current_user)
  end

  def edit
  end

  def new
  end

  def create
    @profile = Profile.new params[:profile]
    assign_entity( @profile )
    @profile.friend = true
    @notes = @profile.notes.build params[:notes].values
    if @profile.save
      redirect_to :controller => 'profiles', :action => 'show'
    else
      render :action => 'new'
    end
  end

  def update
    if @profile.update_attributes params[:profile] and update_dependencies
      respond_to do |format|
        format.html do
          flash[:notice] = "Saved your profile changes"
          redirect_to me_profile_url
        end
        format.xml  { head:ok }
        format.json { head:ok }
      end
    else
      render :action => 'edit'
    end
  end

  def update_dependencies
    ( params[:notes] ? params[:notes].all? { |note_type, note_params|
        @profile.notes[note_type].update_attributes( note_params )
      } : true ) &&
    
    if params[:email_addresses] 
      ( if new_addresses = params[:email_addresses].delete('new') and !new_addresses.all?{ |n| n['email_address'].blank? }
        @profile.email_addresses.create( new_addresses.select{ |n| !n['email_address'].blank?} )
      else
        true
      end ) &&
      @profile.email_addresses.update( params[:email_addresses].keys, params[:email_addresses].values ) 
      
    else 
      true 
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
      if params[:group_id]
        @entity = @group = Group.find(params[:group_id])
        @profile = @group.profile
      else
        @entity = @user = current_user
        @profile = current_user.private_profile || current_user.build_private_profile
      end
      #@profile = current_user.private_profile || 
                  #Profile.new( :entity => current_user, :friend => true ) 
    end

  def authorized?
    #RAILS_DEFAULT_LOGGER.debug "### #authorizing here #{params} -- #{request.namespace}"
    if @entity.is_a?(User) and current_user == @entity
      return true
    elsif @entity.is_a?(Group)
      return true if action_name == 'show'
      return true if logged_in? and current_user.member_of?(@entity)
      return false
    elsif action_name =~ /add_/
     return true # TODO: this is the right way to do this
    end
  end
  
  def assign_entity(profile)
    if @group
      profile.entity = @group
    else
      profile.entity = current_user
    end
  end
  
end
