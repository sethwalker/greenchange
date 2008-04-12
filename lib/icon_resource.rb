module IconResource
  def self.included(base)
    base.caches_page :icon
  end

  def icon
    respond_to do |format|
      format.png do
        @requested_size = params[:size] ? params[:size].to_sym : :default
        #@source = instance_variable_get( "@#{controller_name.singularize}".to_sym ) 
        #raise @source.file_path
        render :partial => 'shared/icon', :locals => { :source => instance_variable_get( "@#{controller_name.singularize}".to_sym )  }
        
      end
    end
  end


end
