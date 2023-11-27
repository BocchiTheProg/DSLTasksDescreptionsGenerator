class Project
  attr_accessor :tasks, :current_task

  def initialize
    @tasks = []
  end

  def create_task(name)
    task = Task.new(name)
    @tasks << task
    task
  end

  def select_task(name)
    @current_task = @tasks.find { |task| task.name == name }
  end

  def sort_by_priority
    @tasks.sort_by!(&:priority)
  end

  def sort_by_due_date
    @tasks.sort_by!(&:due_date)
  end

  def save_to_file(file_name)
    File.open(file_name, 'w') do |file|
      @tasks.each do |task|
        file.write("Task: #{task.name}\n")
        file.write("Description: #{task.description}\n")
        file.write("Priority: #{task.priority}\n")
        file.write("Due Date: #{task.due_date}\n")
        file.write("Executors: #{task.executors.join(', ')}\n\n")
      end
    end
  end

  def execute_command(command)
    case command
    when /^CREATE\("(.+)"\)$/
      create_task($1)
    when /^SELECT\("(.+)"\)$/
      select_task($1)
    when /^DESCRIPTION\("(.+)"\)$/
      @current_task.add_description($1)
    when /^PRIORITY\((\d+)\)$/
      @current_task.add_priority($1.to_i)
    when /^DUE_DATE\("(.+)"\)$/
      @current_task.add_due_date($1)
    when /^EXECUTORS\((.+)\)$/
      @current_task.add_executors($1.split(','))
    when /^SORT_BY_PRIORITY$/
      sort_by_priority
    when /^SORT_BY_DUE_DATE$/
      sort_by_due_date
    when /^SAVE_TO_FILE\("(.+)"\)$/
      save_to_file($1)
    when /^QUIT$/
      exit
    else
      puts "Invalid command"
    end
  end

  def run
    loop do
      print "> "
      command = gets.chomp
      execute_command(command)
    end
  end
end