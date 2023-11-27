class Project
  attr_accessor :tasks, :current_task, :operators

  def initialize
    @tasks = []
    @operators = {}
  end

  def add_operator(name, description)
    @operators[name] = description
  end

  def print_help
    puts "Operators Dictionary"
    @operators.each { |key, description| puts "#{key}\t\t\t| #{description}"}
    puts "** - place where you have to input your argument"
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

  def add_description(description_name, description_value)
    begin
      current_task.instance_variables[0..4].each { |var| raise NameError if var.to_s == "@#{description_name}"}
      @current_task.instance_variable_set("@#{description_name}", description_value)
    rescue NameError
      puts "Impossible name for additional description."
      puts "You can use alphabetical characters and number (don`t start name with number).\nInstead of spacebars, use '_'."
    end
  end

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
        file.write("Executors: #{task.executors.join(', ')}\n")
        if task.instance_variables.size > 5
          file.write"ADDITIONAL DESCRIPTIONS\n"
          task.instance_variables[5..].each do |attr_name|
            attr_value = task.instance_variable_get(attr_name)
            file.write("#{attr_name[1..]}: #{attr_value}\n")
          end
        end
        file.write"\n"
      end
    end
  end

  def load_from_file(file_name)
    @tasks = []
    File.open(file_name, 'r') do |file|
      task = nil
      flag = false
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
        when "ADDITIONAL DESCRIPTIONS\n"
          flag = true
        else
          if line.chomp.empty?
            flag = false
          elsif flag
            description = line.chomp.split(": ")
            @current_task = task
            add_description(description[0], description[1])
          end
        end
      end
    end
    @current_task = nil
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
        if select_task($1).nil?
          puts "No Task was selected (cannot find Task with name #{$1})."
          puts "List of task names in project:"
          @tasks.each { |task| puts task.name}
        else
          @current_task = select_task($1)
          puts "Task: #{$1} was selected."
        end
      when /^DESCRIPTION\("(.+)"\)$/
        @current_task.add_description($1)
      when /^PRIORITY\((\d+)\)$/
        @current_task.add_priority($1.to_i)
      when /^DUE_DATE\("(.+)"\)$/
        date_regex = /^\d{4}-\d{2}-\d{2}$/
        date = $1
        if date.match(date_regex)
          @current_task.add_due_date(date)
        else
          puts "Invalid date format."
          puts "Use: \"yyyy-mm-dd\""
        end
      when /^EXECUTORS\("(.+)"\)$/
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
      when /^ADDITIONAL_DESCRIPTION\("(.+),(.+)"\)$/
        raise NoMethodError if @current_task.nil?
        add_description($1, $2)
      when /^SORT_BY_PRIORITY\("(.+)"\)$/
        sort_by_priority($1)
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
        print_help
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

  def run(&block)
    puts "Tasks Descriptions Generator"
    instance_eval(&block)
    loop do
      print "> "
      command = gets.chomp
      execute_command(command)
    end
  end
end