class TaskCompletedAndDueDates < ActiveRecord::Migration
  def self.up
    add_column    :tasks,     :completed_at,     :datetime
    Task::Task.reset_column_information
    Task::Task.update_all "completed_at = '#{Time.now.to_s :db}'", "completed"
    remove_index  :tasks,     :name => 'index_tasks_completed_positions'
    add_index     :tasks,     ['task_list_id', 'completed_at', 'position'], :name => 'index_tasks_completed_positions'
    remove_column :tasks,     :completed  
    add_column    :tasks,     :due_at,            :datetime
  end

  def self.down
    remove_index  :tasks,     :name => 'index_tasks_completed_positions'
    add_column :tasks,        :completed,         :boolean
    Task::Task.reset_column_information
    Task::Task.update_all "completed = 1", "!isnull(completed_at)"
    remove_column :tasks,     :completed_at
    remove_column :tasks,     :due_at
    add_index     :tasks,     ['task_list_id', 'completed', 'position'], :name => 'index_tasks_completed_positions'
  end
end
