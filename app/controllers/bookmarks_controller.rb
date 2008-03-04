class BookmarksController < ApplicationController
  make_resourceful do
    actions :all
    belongs_to :page
    before(:create) { current_object.user = current_user }
  end
end
