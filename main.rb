require_relative './task'
require_relative './project'

project = Project.new

project.run do
  # adding operators using block
  add_operator("CREATE", "CREATE *Task name* - create new Task in project (created Task become selected).")
  add_operator("DELETE", "DELETE *Task name* - delete Task from project.")
  add_operator("SELECT", "SELECT *Task name* - select certain Task in project.")
  add_operator("DESCRIPTION", "DESCRIPTION *Text of description* - add(set) text description to selected Task.")
  add_operator("PRIORITY", "PRIORITY *A non-negative integer* - add(set) priority of selected Task.")
  add_operator("DUE DATE", "DUE DATE *date in format: yyyy-mm-dd* - add(set) due date of selected Task.")
  add_operator("EXECUTORS", "EXECUTORS *executors separated by a comma* - add(set) list of executors to selected Task.")
  add_operator("ADDITIONAL DESCRIPTION", "ADDITIONAL DESCRIPTION *name and value(text) of description, separated with colon ':'* - add(set) unique description to selected Task.")
  add_operator("SORT BY PRIORITY", "SORT BY PRIORITY *order of sorting, it can be: INCR(Increase) or DECR(Decrease)* - sort all created Tasks by priority from 0 to max or vise versa.")
  add_operator("SORT BY DUE DATE", "SORT BY DUE DATE - sort all created Tasks by due time from the earliest to the latest.")
  add_operator("SAVE TO FILE", "SAVE TO FILE *file name or path* - save all created Tasks of project in text file.")
  add_operator("LOAD FROM FILE", "LOAD FROM FILE *file name or path* - load all Tasks (and their descriptions) of project from some text file.")
  add_operator("QUIT", "QUIT - end the work, close program.")
  print_help
end
