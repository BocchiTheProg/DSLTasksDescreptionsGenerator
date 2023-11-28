require_relative './task'
require_relative './project'

project = Project.new

project.run do
  add_operator("CREATE", "CREATE(\"*Task name*\") - create new Task in project")
  add_operator("DELETE", "DELETE(\"*Task name*\") - delete Task from project")
  add_operator("SELECT", "SELECT(\"*Task name*\") - select certain Task in project")
  add_operator("DESCRIPTION", "DESCRIPTION(\"*Text of description*\") - add(set) text description to Task which was selected with SELECT")
  add_operator("PRIORITY", "PRIORITY(*A non-negative integer*) - add(set) priority of Task which was selected with SELECT")
  add_operator("DUE_DATE", "DUE_DATE(\"*date in format: yyyy-mm-dd*\") - add(set) due date of Task which was selected with SELECT")
  add_operator("EXECUTORS", "EXECUTORS(\"*executors separated by a comma*\") - add(set) list of executors to Task which was selected with SELECT")
  add_operator("ADDITIONAL_DESCRIPTION", "ADDITIONAL_DESCRIPTION(\"*name and value(text) of description, separated with comma*\") - add(set) unique description to Task which was selected with SELECT")
  add_operator("SORT_BY_PRIORITY", "SORT_BY_PRIORITY(\"*order of sorting, it can be: INCR(Increment) or DECR(Decrease)*\") - sort all created Tasks by priority from 0 to max or vise versa")
  add_operator("SORT_BY_DUE_DATE", "SORT_BY_DUE_DATE - sort all created Tasks by due time from the earliest to the latest")
  add_operator("SAVE_TO_FILE", "SAVE_TO_FILE(\"*file name or path*\") - save all created Task of project in text file")
  add_operator("LOAD_FROM_FILE", "LOAD_FROM_FILE(\"*file name or path*\") - load all Task (and their descriptions) of project from some text file")
  add_operator("QUIT", "QUIT - end the work, close program")
  print_help
end
