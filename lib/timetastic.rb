require 'date'
require 'time'

module Timetastic
  Domains = [ :hours, :weeks, :days, :months, :years ]

  class << self
    attr_accessor :fixed_time # see Timetastic#fixate() below

    def last(delta = 1, relative_to = nil)
      Traveller.new(-1, delta, relative_to)
    end

    alias_method :past, :last

    def next(delta = 1, relative_to = nil)
      Traveller.new(1, delta, relative_to)
    end

    alias_method :coming, :next

    # Fixes the relative time by which all of Timetastic operations
    # are carried out for the duration of the given block.
    #
    # Mainly used for tests and gem development.
    #
    # An alternative way to 'fix' the time is to directly use the exposed
    # attribute Timetastic#fixed_time, ie:
    #
    # => Timetastic.fixed_time = Time.new(Time.now.year, 6, 1)
    #
    # You can simply set the attribute to nil to reset the time back to Time.now
    def fixate(y, m = 1, d = 1, h = 0, mi = 0, s = 0, &block)
      @fixed_time = Time.new(y,m,d,h,mi,s)
      block.call(@fixed_time)
      @fixed_time = nil
    end

    # Snippet that calculates the number of days in any given month
    # taking into account leap years.
    #
    # Credit goes to this SO thread: bit.ly/4GjMor
    def days_in_month(year, month)
      (Date.new(year, 12, 31) << (12-month)).day
    end

    # Returns the relative time by which operations are carried out
    def now()
      @fixed_time || Time.now
    end
  end

  private

  class Traveller
    attr_reader :direction, :distance

    def initialize(direction, distance, relative_to = nil)
      @distance = distance.to_i
      @relative_to = relative_to
      @direction = case direction
      when -1; :ago
      when  1; :hence
      end
    end

    Domains.each { |domain|
      define_method(domain) { relative_anchored_time(domain) }
      alias_method :"#{domain[0..-2]}", domain
    }

    protected

    def relative_anchored_time(domain)
      t = @distance.send(domain).send(@direction, @relative_to)

      case domain
      when :days, :weeks;
        Time.new(t.year, t.month, t.day)
      when :months; Time.new(t.year, t.month, 1)
      when :years;  Time.new(t.year, 1, 1)
      end
    end
  end # Timetastic::Traveller

end # end of Module#Timetastic

class Fixnum
  Timetastic::Domains.each do |domain|
    define_method(domain) { @time_offset_domain = domain; self }

    # an alias for the singular version of the domain
    alias_method :"#{domain[0..-2]}", domain
  end

  def ago(relative_to = nil)
    relative_time(-1, relative_to)
  end

  def hence(relative_to = nil)
    relative_time(1, relative_to)
  end

  alias_method :ahead, :hence
  alias_method :from_now, :hence

  protected

  attr_reader :time_offset_domain

  def relative_time(coef, relative_to = nil)
    d = (coef.to_i) / (coef.to_i.abs) * self # delta
    n = relative_to || Timetastic.now

    case @time_offset_domain
    when :hours
      # TODO: OOR wrapping

      if n.hour + d <= 0
        n = 1.day.ago
        Time.new(n.year, n.month, n.day, 24 - (d.abs - n.hour), n.min, n.sec)
      # is it the last hour?
      elsif n.hour + d <= 24
        Time.new(n.year, n.month, n.day, n.hour + d, n.min, n.sec)
      else
        # it's some hour of the next day
        n = 1.day.ahead
        Time.new(n.year, n.month, n.day, n.hour + d - 24, n.min, n.sec)
      end

    when :days
      # TODO: OOR wrapping

      # the #days in the current month is used to evaluate whether
      # the target day can be located in the current, past, or next month(s)
      nr_days = Timetastic.days_in_month(n.year, n.month)

      # target day is in the last month, requires a backwards wrap
      if n.day + d <= 0
        # if it's YY-02-2012 then X (>YY) days ago is:
        # [nr_days(january) - (X - YY)]
        i = n.day
        n = 1.month.ago

        nr_days = Timetastic.days_in_month(n.year, n.month)
        Time.new(n.year, n.month, nr_days - (d.abs - i), n.hour, n.min, n.sec)

      # the day is located in this month
      elsif n.day + d <= nr_days
        Time.new(n.year, n.month, n.day + d, n.hour, n.min, n.sec)

      # target is in the next month, requires a forward wrap
      else
        n = 1.month.ahead # locate the next month
        Time.new(n.year, n.month, n.day + d - nr_days, n.hour, n.min, n.sec)
      end

    when :weeks
      # TODO: OOR wrapping

      d *= 7
      nr_days = Timetastic.days_in_month(n.year, n.month)

      if n.day + d <= 0
        i = n.day
        n = 1.month.ago
        nr_days = Timetastic.days_in_month(n.year, n.month)

        Time.new(n.year, n.month, nr_days - (d.abs - i), n.hour, n.min, n.sec)
      elsif n.day + d <= nr_days
        Time.new(n.year, n.month, n.day + d, n.hour, n.min, n.sec)
      else
        n = 1.month.ahead
        Time.new(n.year, n.month, n.day + d - nr_days, n.hour, n.min, n.sec)
      end
    when :months
      # some past year
      if n.month + d <= 0
        # how many years to go back?
        nr_years_back = ((d + n.month) / 12.0).abs.floor + 1

        n = nr_years_back.year.ago
        Time.new(n.year, 12 * nr_years_back - (d.abs - n.month), n.day, n.hour, n.min, n.sec)

      # current year
      elsif n.month + d <= 12
        Time.new(n.year, n.month + d, n.day, n.hour, n.min, n.sec)

      # some future year
      else
        # puts "#{d} + #{n.month} => #{((d - n.month) / 12.0).ceil}"
        # how many years ahead?
        nr_years_ahead = ((d - n.month) / 12.0).ceil
        nr_years_ahead = 1 if nr_years_ahead == 0
        n = nr_years_ahead.year.ahead
        Time.new(n.year, n.month + d - 12 * nr_years_ahead, n.day, n.hour, n.min, n.sec)
      end
    when :years
      # there's no wrapping here, only a single case
      Time.new(n.year + d, n.month, n.day, n.hour, n.min, n.sec)
    end
  end

end