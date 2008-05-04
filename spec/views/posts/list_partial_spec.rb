require File.dirname(__FILE__) + '/../../spec_helper'

describe '/posts/_list.rhtml' do
  describe "when paginating" do

    before do
      Post.delete_all
      @posts = []
      20.times do 
        p = Post.new :body => 'post'
        p.stub!(:group_name).and_return('grouple')
        p.user = create_valid_user
        p.created_at = Time.now.to_s :db
        p.save(false)
        @posts << p
      end
    end


    it "should be pulling from a list of 20 posts" do
      Post.find(:all).size.should == 20
    end

    it "should render pagination correctly when on page 1" do
      assigns[:posts] = Post.paginate(:all, :page => 1, :per_page => 2)
      template.stub_render 'posts/_post'
      render "/posts/_list"
      response.should have_tag('div.pagination') do
        with_tag('ul') do
          with_tag('li.disablepage', '&laquo; previous')
          with_tag('li.currentpage', '1')
          with_tag('li', '2') { with_tag('a') }
          with_tag('li', '3') { with_tag('a') }
          with_tag('li') { with_tag('a', '10') }
          with_tag('li.nextpage', 'next &raquo;') { with_tag('a') }
        end
      end
    end

    it "should render pagination correctly on page 5" do
      assigns[:posts] = Post.paginate(:all, :page => 5, :per_page => 2)
      template.stub_render 'posts/_post'
      render "/posts/_list"
      response.should have_tag('div.pagination') do
        with_tag('ul') do
          with_tag('li.nextpage') { with_tag('a', '&laquo; previous') }
          1.upto(4) do |n|
            with_tag('li', n.to_s) { with_tag('a') } 
          end
          with_tag('li.currentpage', '5')
          with_tag('li') { with_tag('a', '10') }
          with_tag('li.nextpage', 'next &raquo;') { with_tag('a') }
        end
      end
    end

    it "should render pagination correctly on page 10" do
      assigns[:posts] = Post.paginate(:all, :page => 10, :per_page => 2)
      template.stub_render 'posts/_post'
      render "/posts/_list"
      response.should have_tag('div.pagination') do
        with_tag('ul') do
          with_tag('li.nextpage') { with_tag('a', '&laquo; previous') }
          1.upto(9) do |n|
            with_tag('li', n.to_s) { with_tag('a') } 
          end
          with_tag('li.currentpage', '10')
          with_tag('li.disablepage', 'next &raquo;')
        end
      end
    end
  end
end
