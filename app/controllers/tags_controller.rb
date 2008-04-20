class TagsController < ApplicationController
  def show
    @tag = Tag.find_by_name(params[:id])
    @pages = @tag.pages.allowed(current_user, :view).find(:all, :order => 'pages.updated_at DESC', :limit => 20)
  end

end
