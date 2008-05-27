class PreferencesController < ApplicationController
  before_filter :login_required

  def index
    @preferences = @person.preferences
  end

  def create
    @preference = @person.preferences.find_or_create_by_name params[:preference][:name]
    if @preference.update_attributes params[:preference]
      respond_to do |format|
        format.html{ head :ok }
        format.json{ head :ok }
        format.xml { head :ok }
      end
    else
      respond_to do |format|
        format.html{ render :text => @preference.errors, :status=> :unprocessable_entity }
        format.json{ render :json => @preference.errors, :status => :unprocessable_entity}
        format.xml { render :xml => @preference.errors, :status => :unprocessable_entity}
      end
    
    end
    
  end
  
  
  protected 

  def load_context
    @person = @me = current_user
  end
end
