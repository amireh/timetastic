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

    def this()
      Traveller.new(1, 0)
    end

    def days_between(b, e)
      (e.to_i - b.to_i) / 60 / 60 / 24
    end

    def days_and_months_between(b, e)
      # WARN: BUGGY! is capped @ 12 months (does not account for year wrapping)
      t = Time.at(e.to_i - b.to_i)
      [ t.day, t.month ]
    end

    def months_between(b, e)
      ((e.to_i - b.to_i) / 2.62974e6).ceil
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
      lock_time do
        if y.is_a?(Time)
          @fixed_time = y
        elsif y.respond_to?(:to_time)
          @fixed_time = y.to_time
        else
          @fixed_time = Time.new(y,m,d,h,mi,s)
        end

        block.call(@fixed_time)

        @fixed_time = nil
      end
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

    private

    def lock_time(&callback)
      @fixed_time_lock ||= Mutex.new
      @fixed_time_lock.synchronize do
        yield if block_given?
      end
    end
  end

  private

  class Traveller
    attr_reader :direction, :distance

    def initialize(direction, distance, relative_to = nil)
      @distance = distance.to_i
      @relative_to = relative_to || Timetastic.now
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
      if domain == :months
        if @relative_to.day < 3
          @relative_to = Time.new(@relative_to.year, @relative_to.month, @relative_to.day + 3)
        end
      end

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

module TimetasticFixnum
  class << self
    def time_offset_domain
      @tod ||= {}
    end
  end

  def time_offset_domain
    TimetasticFixnum.time_offset_domain[self]
  end

  def set_time_offset_domain(v)
    TimetasticFixnum.time_offset_domain[self] = v
  end

end

class Fixnum
  include TimetasticFixnum

  Timetastic::Domains.each do |domain|
    define_method(domain) {
      set_time_offset_domain( domain )

      self
    }

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

  # attr_reader :time_offset_domain

  def relative_time(coef, relative_to = nil)
    d = (coef.to_i) / (coef.to_i.abs) * self # delta
    n = relative_to || Timetastic.now

    case time_offset_domain
    when :hours
      Time.at(n.to_i + d * 3600)
    when :days
      Time.at(n.to_i + d * 86400)
    when :weeks
      Time.at(n.to_i + d * 604800)
    when :months
      Time.at(n.to_i + d * 2592000)
    when :years
      Time.new(n.year + d, n.month, n.day, n.hour, n.min, n.sec)
    end
  end

end