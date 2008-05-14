class ProfilesController < ApplicationController
  before_filter :login_required, :except => :show
  before_filter :fetch_profile
  before_filter :initialize_profile_collections, :except => :show

  helper :profile
  include IconResource
  icon_resource :person

  def show
    current_user.may! :view, @profile
  end

  def edit
    current_user.may! :edit, @profile
  end

  def update
    @profile.attributes= params[:profile] 
    if update_profile_collections and @profile.save 
      respond_to do |format|
        format.html do
          flash[:notice] = "Saved your profile changes"
          redirect_to (current_user == @profile.entity ? me_profile_path : person_profile_path( @profile.entity ) )
        end
        format.xml  { head:ok }
        format.json { head:ok }
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    current_user.may! :admin, @profile
    @profile.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = "Deleted profile record"
        redirect_to me_path
      end
      format.xml  { head:ok }
      format.json { head:ok }
    end
  end

=begin
  def create
    @profile = Profile.new params[:profile]
    @profile.entity = ( @person || current_user )
    @profile.friend = true
    update_profile_collections
    if update_profile_collections && @profile.save 
      redirect_to :controller => 'profiles', :action => 'show'
    else
      render :action => 'new'
    end
  end
=end

  private
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

      if params[:user] && @profile.user
          success = success &&
            @profile.user.update_attributes( params[:user] )
      end
      
      success = success &&
        [ :email_addresses, :im_addresses, :web_resources, :phone_numbers, :locations ].all? do |collection| 
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
        blank_items = new_items.delete_if {|item| item.all?{ |k, v| v.blank? or k.to_s =~ /_type$/ }} 
        updated_collection += profile_collection.build( new_items ) unless new_items.empty?
      end
      updated_collection
      
    end

    def fetch_profile
      if @me
        @profile = current_user.private_profile || current_user.build_private_profile
      elsif @person
        @profile = @person.profile_for( current_user )
      end
    end

    def initialize_profile_collections
      if @profile
        @email_addresses ||= @profile.email_addresses
        @im_addresses   ||= @profile.im_addresses 
        @phone_numbers  ||= @profile.phone_numbers
        @locations      ||= @profile.locations
        @web_resources  ||= @profile.web_resources
        @languages      ||= @profile.languages
        @notes          ||= @profile.notes
        @person         ||= @profile.user
      end
    end

end
