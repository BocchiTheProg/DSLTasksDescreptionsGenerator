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

  def delete_task(name)
    @tasks.delete_if { |task| task.name == name }
  end

  def select_task(name)
    @tasks.find { |task| task.name == name }
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

  def load_from_file(file_name)
    @tasks = []
    @current_task = nil
    File.open(file_name, 'r') do |file|
      task = nil
      file.each_line do |line|
        case line
        when /^Task: (.+)$/
          task = create_task($1)
        when /^Description: (.+)$/
          task.add_description($1)
        when /^Priority: (\d+)$/
          task.add_priority($1.to_i)
        when /^Due Date: (.+)$/
          task.add_due_date($1)
        when /^Executors: (.+)$/
          task.add_executors($1.split(', '))
        end
      end
    end
  end

  def ask_yn_question(question)
    puts "#{question} [y,n]"
    print "> "
    option = gets.chomp.downcase
    option == "y"
  end

  def execute_command(command)
    begin
      case command
      when /^CREATE\("(.+)"\)$/
        if select_task($1).nil?
          create_task($1)
        else
          puts "Task with name #{$1} already exist."
          if ask_yn_question("Do you want to recreate this Task?")
            delete_task($1)
            create_task($1)
          end
        end
      when /^DELETE\("(.+)"\)$/
        delete_task($1)
      when /^SELECT\("(.+)"\)$/
        if (@current_task = select_task($1)).nil?
          puts "No Task was selected (cannot find Task with name #{$1}.)"
          puts "List of task names in project:"
          @tasks.each { |task| puts task.name}
        else
          puts "Task: #{$1} was selected."
        end
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
      when /^LOAD_FROM_FILE\("(.+)"\)$/
        load_from_file($1)
      when /^QUIT$/
        exit
      else
        puts "Invalid command"
      end
    rescue NoMethodError => e
      if @current_task.nil?
        puts "Cant add descriptions, no Task was selected."
        puts "Use SELECT operator."
      else
        puts "Error #{e.message}"
      end
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