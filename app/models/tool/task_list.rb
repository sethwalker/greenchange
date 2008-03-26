require 'task/task_list'

class Tool::TaskList < Page

  icon 'task-list.png'
  class_display_name 'task list'
  class_description 'A list of todo items.'
  belongs_to :data, :class_name => 'Task::TaskList'
    
end
