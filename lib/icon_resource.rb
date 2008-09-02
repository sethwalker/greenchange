module IconResource
  def self.included(base)
    base.caches_page :icon
    base.after_filter :refresh_icon, :only => :update
    base.cattr_accessor :icon_resource_name
    base.class_eval do
      def self.icon_resource( name )
        self.icon_resource_name = name
      end
    end
  end

  def icon
    raise ActiveRecord::RecordNotFound unless icon_resource
    respond_to do |format|
      format.png do
        @requested_size = params[:size] ? params[:size].to_sym : :default
        render :partial => 'shared/icon', :locals => { :source => icon_resource }
        
      end
    end
  end

  def icon_resource
    resource_name = self.class.icon_resource_name || controller_name.singularize
    instance_variable_get "@#{resource_name}".to_sym
  end
  
  protected
    # this clears the cached icon when the model is updated
    # depends on a @model instance variable being set in the update method
    def refresh_icon
      raise "Missing an instance of @#{self.class.icon_resource_name} to clear cache" unless icon_resource
      Crabgrass::Config.image_sizes.merge({:default => 'x'}).each do |size, dimensions| 
        icon_path = icon_path_for( icon_resource, :size => size )
        expire_page( icon_path.gsub(/\?\d+$/, '') ) if icon_path
      end
      true
    end


end
