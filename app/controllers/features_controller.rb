# Feature users and groups
class FeaturesController < ApplicationController
  before_filter :superuser_required, :target_required

  def create
    if @featured.update_attribute :featured, true
      flash[:notice] = "#{@featured.display_name} is now featured"
    else
      flash[:notice] = "Unable to feature #{@featured.display_name}"
    end
    if @featured == current_user
      featured_path = person_path(@featured)
    else
      featured_path = send( (context_path_prefix_type( @featured ) + '_path').to_sym, @featured )
    end
    redirect_to featured_path and return
  end
  def destroy
    if @featured.update_attribute :featured, false
      flash[:notice] = "#{@featured.display_name} is no longer featured"
    else
      flash[:notice] = "There is a problem removing #{@featured.display_name} from features"
    end
    if @featured == current_user
      featured_path = person_path(@featured)
    else
      featured_path = send( (context_path_prefix_type( @featured ) + '_path').to_sym, @featured )
    end
    redirect_to featured_path and return
  end

  protected
  def target_required
    @featured = (@group || @person)
    raise ActiveRecord::RecordNotFound unless @featured
  end
end
