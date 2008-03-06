require File.dirname(__FILE__) + '/../../spec_helper'

describe '/posts/_list.rhtml' do
  describe "when paginating" do

    def paginator(page)
      ActionController::Pagination::Paginator.new stub('controller'), @disc.posts.count, @disc.per_page, page
    end

    before do
      posts = []
      @disc = mock_model(Discussion, :posts => stub('posts', :count => 100, :find => posts), :per_page => 2)
    end

    it "should render pagination correctly when on page 1" do
      assigns[:post_paging] = paginator(1)
      render "/posts/_list"
      response.should have_tag('div.pagination') do
        with_tag('ul') do
          with_tag('li.disablepage', '&laquo; previous')
          with_tag('li.currentpage', '1')
          with_tag('li', '2') { with_tag('a') }
          with_tag('li', '3') { with_tag('a') }
          with_tag('li') { with_tag('a', '50') }
          with_tag('li.nextpage', 'next &raquo;') { with_tag('a') }
        end
      end
    end

    it "should render pagination correctly on page 10" do
      assigns[:post_paging] = paginator(10)
      render "/posts/_list"
      response.should have_tag('div.pagination') do
        with_tag('ul') do
          with_tag('li.nextpage') { with_tag('a', '&laquo; previous') }
          1.upto(9) do |n|
            with_tag('li', n.to_s) { with_tag('a') } 
          end
          with_tag('li.currentpage', '10')
          with_tag('li') { with_tag('a', '50') }
          with_tag('li.nextpage', 'next &raquo;') { with_tag('a') }
        end
      end
    end

    it "should render pagination correctly on page 50" do
      assigns[:post_paging] = paginator(50)
      render "/posts/_list"
      response.should have_tag('div.pagination') do
        with_tag('ul') do
          with_tag('li.nextpage') { with_tag('a', '&laquo; previous') }
          1.upto(49) do |n|
            with_tag('li', n.to_s) { with_tag('a') } 
          end
          with_tag('li.currentpage', '50')
          with_tag('li.disablepage', 'next &raquo;')
        end
      end
    end
  end
end
