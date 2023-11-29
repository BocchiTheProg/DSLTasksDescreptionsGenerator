# class to represent task
class Task
  attr_reader :name, :description, :priority, :due_date, :executors, :additional_description

  def initialize(name)
    # main description characteristics
    @name = name
    @description = ''
    @priority = 0
    @due_date = ''
    @executors = []
    # unique description characteristics
    @additional_description = {}
  end

  def add_description(description)
    @description = description
  end

  def add_priority(priority)
    @priority = priority
  end

  def add_due_date(due_date)
    @due_date = due_date
  end

  def add_executors(executors)
    @executors = executors
  end

  def add_additional_description(name, description)
    @additional_description[name] = description
  end
end