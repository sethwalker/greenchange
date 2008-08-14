class FeaturesController < ApplicationController
  before_filter :superuser_required, :target_required

  def create
    if @featured.update_attribute :featured, true
      flash[:notice] = "#{@featured.display_name} is now featured"
    else
      flash[:notice] = "Unable to feature #{@featured.display_name}"
    end
    featured_path = send( (context_path_prefix_type( @featured ) + '_path').to_sym, @featured )
    redirect_to featured_path and return
  end
  def destroy
    if @featured.update_attribute :featured, false
      flash[:notice] = "#{@featured.display_name} is no longer featured"
    else
      flash[:notice] = "There is a problem removing #{@featured.display_name} from features"
    end
    featured_path = send( (context_path_prefix_type( @featured ) + '_path').to_sym, @featured )
    redirect_to featured_path and return
  end

  protected
  def target_required
    @featured = (@group || @person)
    raise ActiveRecord::RecordNotFound unless @featured
  end
  def superuser_required
    raise PermissionDenied unless current_user and current_user.superuser?
  end
end