class SearchController < ApplicationController
  def index
    @items = ThinkingSphinx::Search.search(params[:query], :page => params[:page])
  end
end
