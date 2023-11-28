# class to represent task
class Task
  # main description characteristics
  attr_reader :name, :description, :priority, :due_date, :executors

  def initialize(name)
    @name = name
    @description = ''
    @priority = 0
    @due_date = ''
    @executors = []
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
end