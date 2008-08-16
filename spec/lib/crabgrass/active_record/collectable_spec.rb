require File.dirname(__FILE__) + '/../../../spec_helper'

describe Crabgrass::ActiveRecord::Collectable do

  before :all do
    Page.__send__ :include, Crabgrass::ActiveRecord::Collectable
    Page.__send__ :is_collectable
  end

  before do
    @user = create_user
    @user.public_collection   << ( @public_page =   create_page )
    @user.private_collection  << ( @private_page =  create_page )
    @user.social_collection   << ( @social_page =   create_page )
  end

  it "should allow private items to be viewed by the creating user" do
    Page.allowed(@user).should include(@private_page)
  end

  it "should not allow private items to be viewed by another user" do
    new_user = create_user
    Collecting.allowed(new_user).should_not include(@private_page)
  end

end
