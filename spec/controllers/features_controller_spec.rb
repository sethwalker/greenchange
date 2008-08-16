require File.dirname(__FILE__) + '/../spec_helper'

describe FeaturesController do
  before do
    login_user(@user = new_user(:superuser => true))
  end
  it "only allows superusers to do anything" do
    controller.should_receive( :superuser_required )
    Group.stub!(:find_by_name).and_return(create_group)
    post :create, :group_id => 1 
  end
  describe "POST #create" do
    before do
      @group = create_group
    end
    def act!
      post :create, :group_id => @group.to_param
    end
    it "requires a group or a user" do
      lambda{ post :create }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "sets featured to true on a targeted group" do
      Group.should_receive(:find_by_name).and_return(@group)
      @group.should_receive(:update_attribute).with( :featured, true )
      act!
    end
    it "sets featured to true on a targeted person" do
      @person = create_user
      User.should_receive(:find_by_login).and_return(@person)
      @person.should_receive(:update_attribute).with( :featured, true )
      post :create, :person_id => @person.to_param
    end

    it "redirects to the featured item" do
      Group.should_receive(:find_by_name).and_return(@group)
      act!
      @response.should redirect_to( group_path(@group))
    end

    
  end
  describe "DELETE #destroy" do
    it "sets featured to false" do
      @group = create_group
      Group.stub!(:find_by_name).and_return(@group)
      @group.should_receive(:update_attribute).with(:featured, false)
      delete :destroy, :group_id => @group.to_param
    end
  end
end
