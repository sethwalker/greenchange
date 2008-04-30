require File.dirname(__FILE__) + '/../../spec_helper'

describe "groups/archive_list" do
  it "should render" do
    pending "rewrite the archive list"
    TzTime.zone = TimeZone[DEFAULT_TZ]
    assigns[:months] = [{'month' => '12', 'year' => '2008'}, {'month' => '2', 'year' => '2008'}]
    create_valid_page(:created_at => Date.new(2007, 12))
    create_valid_page(:created_at => Date.new(2008, 2))
    35.times { create_valid_page(:created_at => Date.new(2007, 12)) }
    assigns[:pages] = Page.paginate(:page => 1)
    assigns[:parsed] = PathFinder::Builder.parse_filter_path(['month', '12', 'year', '2007'])
    render "groups/_archive_list"
    response.should have_tag("div.pagination")
  end
end
