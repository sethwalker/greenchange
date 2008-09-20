class SearchController < ApplicationController
  def index
    @items = ThinkingSphinx::Search.search(params[:query], :with => {:public => 1, :searchable => 1}, :page => params[:page])
  end
end
