class Task::TaskList < ActiveRecord::Base
  
  # destroy() freaks out if we use :delete_all, so we use :destroy
  has_many :tasks, :class_name => 'Task::Task', :foreign_key => 'task_list_id',
    :order => "position", :dependent => :destroy, :include => :users

  has_many :completed, :class_name => 'Task::Task', :foreign_key => 'task_list_id',
    :order => "position", :conditions => 'tasks.completed_at IS NOT NULL', :include => :users
    
  has_many :pending, :class_name => 'Task::Task', :foreign_key => 'task_list_id',
    :order => "position", :conditions => 'tasks.completed_at IS NULL', :include => :users
  
  has_many :pages, :as => :data
  def page; pages.first; end
  
end
