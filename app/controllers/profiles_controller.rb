class ProfilesController < ApplicationController
  before_filter :login_required, :except => :show
  prepend_before_filter :fetch_profile, :except => :show
  before_filter :initialize_profile_collections, :except => :show

  helper :profile

  def show
    @person = params[:person_id] ?  User.find_by_login( params[:person_id] ) : current_user
    raise PermissionDenied unless @person.is_a?(AuthenticatedUser) and @profile = @person.profile_for(current_user) 
    initialize_profile_collections
  end

  def edit
  end

  def initialize_profile_collections
    if @profile
      @email_addresses ||= @profile.email_addresses
      @im_addresses   ||= @profile.im_addresses 
      @phone_numbers  ||= @profile.phone_numbers
      @locations      ||= @profile.locations
      @websites       ||= @profile.websites
      @notes          ||= @profile.notes
    end
  end

  def new
  end

  def create
    @profile = Profile.new params[:profile]
    assign_entity( @profile )
    @profile.friend = true
    update_profile_collections
    if update_profile_collections && @profile.save 
      redirect_to :controller => 'profiles', :action => 'show'
    else
      render :action => 'new'
    end
  end

  def update
    @profile.attributes= params[:profile] 
    if update_profile_collections and @profile.save 
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

  def update_profile_collections
    
    success = true
    if params[:notes] 
      success = success &&
        params[:notes].each do |note_type, note_params|
          @profile.notes[note_type].update_attributes!( note_params )
        end  
    end
  
    if params[:issue_ids]
      success = success &&
        @profile.entity.update_attributes( :issue_ids => params[:issue_ids] )
    end
    
    success = success &&
      [ :email_addresses, :im_addresses, :phone_numbers ].all? do |collection| 
         if params[ collection ] 
           updated_collection = update_dependent_collection( collection, params[ collection ]) 
           instance_variable_set "@#{collection}".to_sym, updated_collection
           updated_collection.all?(&:valid?)
          else
           true
          end
      end
  end

  def update_dependent_collection( collection, new_values )
    return true unless new_values
    profile_collection = @profile.send( collection )
    new_items = new_values.delete('new')
    updated_collection = []
    unless new_values.empty?
      updated_collection = profile_collection.update( new_values.keys, new_values.values )
    end
    if new_items
      blank_items = new_items.delete_if {|item| item[ collection.to_s.singularize ].blank? } 
      updated_collection += profile_collection.build( new_items ) unless new_items.empty?
    end
    updated_collection
    
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
    if @entity.is_a?(User) and current_user == @entity
      return true
    elsif @entity.is_a?(Group)
      return true if action_name == 'show'
      return true if logged_in? and current_user.member_of?(@entity)
      return false
    elsif action_name =~ /add_/
     return true 
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
