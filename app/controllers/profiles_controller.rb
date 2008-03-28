class ProfilesController < ApplicationController
  before_filter :login_required, :except => :show
  prepend_before_filter :fetch_profile, :except => :show
  rescue_from ActiveRecord::RecordInvalid do |exception|
    if controller.action_name == 'update'
      render :action => 'edit' 
    elsif controller.action_name == 'create'
      render :action => 'new' 
    end
  end
  #rescue_from ActiveRecord::RecordInvalid, :only => :create, :with => lambda{ render :action => 'new' }

  #verify :method => :post,    :only => :create
  #verify :method => :put,     :only => :update
  #verify :method => :delete,  :only => :destroy

  helper :profile

  def show
    @person = params[:person_id] ?  User.find( params[:person_id] ) : current_user
    access_denied unless @person.is_a?(AuthenticatedUser) and @profile = @person.profile_for(current_user)
  end

  def edit
    assign_dependencies
  end

  def assign_dependencies
    @email_addresses ||= @profile.email_addresses
    @im_addresses   ||= @profile.im_addresses 
    @phone_numbers  ||= @profile.phone_numbers
    @locations      ||= @profile.locations
    @websites       ||= @profile.websites
    @notes          ||= @profile.notes
  end

  def new
    assign_dependencies
  end

  def create
    @profile = Profile.new params[:profile]
    assign_entity( @profile )
    @profile.friend = true
    #( @notes = @profile.notes.build params[:notes].values ) if params[:notes]
    update_dependencies
    if @profile.save #&& update_dependencies
      redirect_to :controller => 'profiles', :action => 'show'
    else
      assign_dependencies
      render :action => 'new'
    end
  end

  def update
    @profile.attributes= params[:profile] 
    #update_dependencies 
    if update_dependencies and @profile.save #and update_dependencies
      respond_to do |format|
        format.html do
          flash[:notice] = "Saved your profile changes"
          redirect_to me_profile_url
        end
        format.xml  { head:ok }
        format.json { head:ok }
      end
    else
      assign_dependencies
      render :action => 'edit'
    end
  end

  def update_dependencies
    
    success = true
    if params[:notes] 
      success = success &&
        params[:notes].each do |note_type, note_params|
          @profile.notes[note_type].update_attributes!( note_params )
        end  
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
#    if params[:email_addresses] 
#      ( if new_addresses = params[:email_addresses].delete('new') and !new_addresses.all?{ |n| n['email_address'].blank? }
#        @profile.email_addresses.create( new_addresses.select{ |n| !n['email_address'].blank?} )
#      else
#        true
#      end ) &&
#      @profile.email_addresses.update( params[:email_addresses].keys, params[:email_addresses].values ) 
#      
#     else 
#      true 
#    end
  end

  def update_dependent_collection( collection, new_values )
    return true unless new_values
    profile_collection = @profile.send( collection )
    new_items = new_values.delete('new')
    updated_collection = []
    unless new_values.empty?
      updated_collection = profile_collection.update( new_values.keys, new_values.values )
    end
    #profile_collection.each do |pc_item|
    #  pc_item.update_attributes( new_values[pc_item.id] ) if new_values[pc_item.id]
    #end
    #pp profile_collection
    #puts "-------\n\n"
    if new_items
      blank_items = new_items.delete_if {|item| item[ collection.to_s.singularize ].blank? } 
      updated_collection += profile_collection.build( new_items ) unless new_items.empty?
    end
    updated_collection
    #profile_collection.all?(&:save)
      #new_items && new_items.all?{ |new_item| 
      #new_item[ collection.to_s.singularize ].blank?  ||
      #profile_collection.create!( new_item )
    #} or true
    #@profile.send( collection ).create( new_items.select{ |n| !n[ collection.to_s.singularize ].blank?} )
    #@profile.send( collection ).update( params[ collection ].keys, params[ collection ].values ) 
    #profile_collection.each { |cc| cc.update_attributes! new_values[cc.id] }
    #update_successful = new_collection.all?(&:valid?)
#    unless update_successful
#      new_collection.each do | match |
#        next if match.errors.empty?
#        match.errors.each do |attr, msg|
#          RAILS_DEFAULT_LOGGER.debug "### error was #{ msg } for #{attr} in #{collection}"
#        end
#      end
#      profile_collection.each do |set| 
#        if match = new_collection.find { |new| new.id = set.id }
#          set.attributes = match.attributes
#          match.errors.each do |attr, msg|
#            set.errors.add attr, msg
#          end
#        end
#      end 
#    end
    #new_values.all? { | key, values |
      #result = @profile.send(collection).update( key, values )
      #old_collection = @profile.send(collection)#.update( key, values )
      #result = old_collection.find(key).update_attributes( values )
      #RAILS_DEFAULT_LOGGER.debug "### result was #{ result.inspect } for #{key} in #{collection}"
      #result
    #}
    #create_successful && update_successful
    
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
