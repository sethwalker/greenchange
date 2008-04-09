require File.dirname(__FILE__) + '/../../../spec_helper'

describe "asset/show" do
  it "should be successful" do
    TzTime.zone = TimeZone[DEFAULT_TZ]
    assigns[:page] = @page = Tool::Asset.create( :created_by => User.new, :updated_by => User.new, :created_at => 1.day.ago, :updated_at => (5.minutes.ago), :title => 'assetpage' )
    @page.build_data :size => 1
    #assigns[:asset] = Asset.new :size => 1
    render "tool/asset/show"
  end
end
