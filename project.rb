class Project
  # @current_task is selected task to work with
  attr_accessor :tasks, :current_task, :operators

  def initialize
    @tasks = [] # tasks in project
    @operators = {} # operators to work(manipulate) with project
  end

  # adding operator
  def add_operator(name, description)
    @operators[name] = description
  end

  # operators dictionary
  def print_help
    puts "Operators Dictionary"
    @operators.each { |key, description| puts "#{key}\t\t\t| #{description}"}
    puts "** - place where you have to input your argument"
  end

  # creating new task to project
  def create_task(name)
    task = Task.new(name)
    @tasks << task
    task
  end

  # deleting task from project
  def delete_task(name)
    @tasks.delete_if { |task| task.name == name }
  end

  # selecting task from project
  def select_task(name)
    @tasks.find { |task| task.name == name }
  end

  # adding unique description characteristic for selected task
  def add_description(description_name, description_value)
    name = description_name.tr(':','')
    @current_task.add_additional_description(name.to_sym, description_value)
  end

  # sort all tasks of project by priority
  def sort_by_priority(order)
    if order == "INCR"
      @tasks.sort_by!(&:priority)
    elsif order == "DECR"
      @tasks.sort_by!(&:priority).reverse!
    else
      puts "Invalid argument."
      puts "Use: INCR(Increment) or DECR(Decrease)"
    end
  end

  # sort all tasks of project by due time
  def sort_by_due_date
    @tasks.sort_by!(&:due_date)
  end

  # saving all tasks to file
  def save_to_file(file_name)
    File.open(file_name, 'w') do |file|
      @tasks.each do |task|
        # writing main description characteristics
        file.write("Task: #{task.name}\n")
        file.write("Description: #{task.description}\n")
        file.write("Priority: #{task.priority}\n")
        file.write("Due Date: #{task.due_date}\n")
        file.write("Executors: #{task.executors.join(', ')}\n")
        # writing unique description characteristics (if included in task)
        unless task.additional_description.empty?
          file.write"ADDITIONAL DESCRIPTIONS\n"
          task.additional_description.each do |key, value|
            file.write("#{key.to_s}: #{value}\n")
          end
        end
        file.write"\n"
      end
    end
  end

  # load tasks from file
  def load_from_file(file_name)
    @tasks = []
    begin
      File.open(file_name, 'r') do |file|
        task = nil
        flag = false
        file.each_line do |line|
          case line
            # reading main description characteristics
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
          # reading unique(additional) description characteristics
          when "ADDITIONAL DESCRIPTIONS\n"
            flag = true
          else
            if line.chomp.empty?
              flag = false
            elsif flag
              description = line.chomp.split(": ")
              task.add_additional_description(description[0].to_sym, description[1])
            end
          end
        end
      end
    rescue => e # handling errors when trying to read file
      puts "Can`t find or read the file: #{file_name}."
      puts "Error: #{e.message}"
    end
    # no task selected after loading
    @current_task = nil
  end

  def ask_yn_question(question)
    puts "#{question} [y,n]"
    print "> "
    option = gets.chomp.downcase
    option == "y"
  end

  # parse command(operator) from user input (in console)
  def execute_command(command)
    begin
      case command
      when /^CREATE (.+)$/
        task_name = $1.strip
        if select_task(task_name).nil?
          # select created task
          @current_task = create_task(task_name)
        else
          puts "Task with name #{task_name} already exist."
          if ask_yn_question("Do you want to recreate this Task?")
            delete_task(task_name)
            @current_task = create_task(task_name)
          end
        end
      when /^DELETE (.+)$/
        delete_task($1.strip)
        # unselect task if it was deleted
        @current_task = nil if !@current_task.nil? and @current_task.name == $1.strip
      when /^SELECT (.+)$/
        task_name = $1.strip
        if select_task(task_name).nil?
          puts "No Task was selected (cannot find Task with name #{task_name})."
          puts "List of task names in project:"
          @tasks.each { |task| puts task.name}
        else
          @current_task = select_task(task_name)
          puts "Task: #{$1} was selected."
        end
      when /^DESCRIPTION (.+)$/
        @current_task.add_description($1)
      when /^PRIORITY (\d+)$/
        @current_task.add_priority($1.to_i)
      when /^DUE DATE (.+)$/
        date_regex = /^\d{4}-\d{2}-\d{2}$/
        date = $1.strip
        if date.match(date_regex)
          @current_task.add_due_date(date)
        else
          puts "Invalid date format."
          puts "Use: yyyy-mm-dd"
        end
      when /^EXECUTORS (.+)$/
        execs = $1.split(",")
        execs.map! { |exec| exec.strip}
        if @current_task.executors.empty?
          @current_task.add_executors(execs)
        else
          puts "Task with name #{@current_task.name} already have executors:#{@current_task.executors.join(', ')}."
          if ask_yn_question("Do you want to change it with new executors?")
            @current_task.add_executors(execs)
          elsif ask_yn_question("Do you want to expand it with new executors?")
            execs.each { |exec| @current_task.executors << exec}
          end
        end
      when /^ADDITIONAL DESCRIPTION (.+):(.+)$/
        add_description($1.strip, $2.strip)
      when /^SORT BY PRIORITY (.+)$/
        sort_by_priority($1.strip)
      when /^SORT BY DUE DATE$/
        sort_by_due_date
      when /^SAVE TO FILE (.+)$/
        save_to_file($1)
      when /^LOAD FROM FILE (.+)$/
        load_from_file($1)
      when /^QUIT$/
        exit
      else
        # print operators dictionary if cannot parse command (operator)
        puts "Invalid command"
        print_help
      end
    rescue NoMethodError => e
      if @current_task.nil? # handling error if no task was selected
        puts "Cant add descriptions, no Task was selected."
        puts "Use SELECT operator."
      else
        puts "Error #{e.message}"
      end
    end
  end

  # reading user inputs (in console)
  def run(&block)
    puts "Tasks Descriptions Generator"
    instance_eval(&block)
    loop do
      print "> "
      command = gets.chomp.strip
      execute_command(command)
    end
  end
end