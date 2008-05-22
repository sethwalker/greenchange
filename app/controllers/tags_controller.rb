class TagsController < ApplicationController
  def show
    @tag = Tag.find_by_name(params[:id])
    raise ActiveRecord::RecordNotFound unless @tag
    redirect_to tag_pages_path(@tag)
    @pages = @tag.pages.allowed(current_user, :view).find(:all, :order => 'pages.updated_at DESC', :limit => 20)
  end

end
