class IssueFeatures < ActiveRecord::Migration
  def self.up
    create_table "featurings" do |t|
      t.integer "issue_id", "page_id"
    end
  end

  def self.down
    drop_table "featurings"
  end
end
