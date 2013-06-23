describe Timetastic do
  tt = Timetastic # alias it to reduce clutter

  before do
  end

  after do
  end

  describe "Past features" do

    it "should locate the last year from today" do
      tt.fixate(2012, 8, 1) { |t|
        1.year.ago.should == Time.new(2011, 8, 1)
      }
    end

    it "should locate the last month from today" do
      tt.fixate(2012, 12, 26) { |t|
        1.month.ago.should == Time.new(2012, 11, 26)
      }
    end

    it "should locate the last week from today" do
      tt.fixate(2012, 12, 26) {
        1.week.ago.should == Time.new(2012, 12, 19)
      }
    end

    it "should locate the last day from today" do
      tt.fixate(2012, 12, 26) {
        1.day.ago.should == Time.new(2012, 12, 25)
      }
    end

    it "should locate the last hour from now" do
      tt.fixate(2012, 12, 26, 14) {
        1.hour.ago.should == Time.new(2012, 12, 26, 13)
        12.hours.ago.should == Time.new(2012, 12, 26, 2)
      }
    end

  end # Past locators

  describe "Future locators" do
    it "should locate the coming year from today" do
      tt.fixate(2012, 12, 26) {
        1.year.hence.should == Time.new(2013, 12, 26)
      }
    end

    it "should locate the coming month from today" do
      tt.fixate(2012, 10, 26) {
        1.month.hence.should == Time.new(2012, 11, 25)
      }
    end

    it "should locate the coming week from today" do
      tt.fixate(2012, 12, 20) {
        1.week.ahead.should == Time.new(2012, 12, 27)
      }
    end

    it "should locate the coming day from today" do
      tt.fixate(2012, 12, 26) {
        1.day.hence.should == Time.new(2012, 12, 27)
      }
    end

  end # Future locators

  describe "Anchored past locators" do
    it "should point to the start of last year" do
      tt.fixate(2012, 3, 3, 5, 32, 16) {
        tt.last.year.should == Time.new(2011, 1, 1)
      }
    end

    it "should point to the start of last month" do
      tt.fixate(2012, 4, 16, 5, 32, 16) {
        tt.last.month.should == Time.new(2012, 3, 1)
      }
    end

    it "should point to the start of last day" do
      tt.fixate(2012, 4, 16, 5, 32, 16) {
        tt.last.day.should == Time.new(2012, 4, 15)
      }
    end

    it "should point to the start of the year before last year" do
      tt.fixate(2012, 4, 16, 5, 32, 16) {
        tt.last(2).years.should == Time.new(2010, 1, 1)
      }
    end

    it "should point to the start of the month before last month" do
      tt.fixate(2012, 4, 16, 5, 32, 16) {
        tt.last(2).months.should == Time.new(2012, 2, 1)
      }
    end

    it "should point to the start of the day before last day" do
      tt.fixate(2012, 4, 16, 5, 32, 16) {
        tt.last(2).days.should == Time.new(2012, 4, 14)
      }
    end
  end # Anchored past locators

  describe "Anchored future locators" do
    it "should point to the start of next year" do
      tt.fixate(2012, 4, 16, 5, 32, 16) {
        tt.next.year.should == Time.new(2013, 1, 1)
      }
    end

    it "should point to the start of next month" do
      tt.fixate(2012, 4, 16, 5, 32, 16) {
        tt.next.month.should == Time.new(2012, 5, 1)
      }
    end

    it "should point to the start of next day" do
      tt.fixate(2012, 4, 16, 5, 32, 16) {
        tt.next.day.should == Time.new(2012, 4, 17)
      }
    end

    it "should point to the start of the year after the coming year" do
      tt.fixate(2012, 4, 16, 5, 32, 16) {
        tt.next(2).years.should == Time.new(2014, 1, 1)
      }
    end

    it "should point to the start of the month after the coming month" do
      tt.fixate(2012, 4, 16, 5, 32, 16) {
        tt.next(2).months.should == Time.new(2012, 6, 1)
      }
    end

    it "should point to the start of the day after tomorrow" do
      tt.fixate(2012, 4, 16, 5, 32, 16) {
        tt.next(2).days.should == Time.new(2012, 4, 18)
      }
    end
  end # Anchored future locators

  describe "Forward wrapping" do

    it "should wrap forward a day to locate the hour" do
      tt.fixate(2012, 6, 26, 21) {
        # this shouldn't wrap
        1.hour.ahead.should == Time.new(2012, 6, 26, 22)
        # but this should
        4.hour.ahead.should == Time.new(2012, 6, 27, 1)
      }
    end

    it "should wrap forward a month to locate the day" do
      tt.fixate(2012, 6, 29) {
        # this should wrap
        4.days.ahead.should == Time.new(2012, 7, 3)
        # and this shouldn't
        1.days.ahead.should == Time.new(2012, 6, 30)
      }
    end

    # we know that 2011 is a leap (gregorian) year, and 2012 isn't
    # nr of days in february in a leap year is 28, otherwise it's 29
    it "should wrap forward a month to locate the day in a leap year" do
      tt.fixate(2011, 2, 28) {
        2.days.ahead.should   == Time.new(2011, 3, 2)
        1.days.ahead.should   == Time.new(2011, 3, 1)
        0.days.ahead.should   == Time.new(2011, 2, 28)
        -1.days.ahead.should  == Time.new(2011, 2, 27)
      }
    end

    it "should wrap forward a month to locate the week" do
      tt.fixate(2012, 6, 20) {
        # shouldn't wrap
        1.week.ahead.should == Time.new(2012, 6, 27)
        # this should wrap
        2.weeks.ahead.should == Time.new(2012, 7, 4)
      }


      # february has 29 on non-leap
      tt.fixate(2012, 2, 22) {
        1.week.ahead.should == Time.new(2012, 2, 29)
      }

      # 28 on leap year
      tt.fixate(2011, 2, 22) {
        1.week.ahead.should == Time.new(2011, 3, 1)
      }
    end

    it "should wrap forward a year to locate a month" do
      tt.fixate(2011, 12, 5) {
        1.month.ahead.should == Time.new(2012, 1, 4)
      }
    end
  end # Forward wrapping

  describe "Backwards wrapping" do
    it "should wrap backwards a day to locate the hour" do
      tt.fixate(2012, 6, 26, 1) {
        # this shouldn't wrap
        1.hour.ago.should == Time.new(2012, 6, 26, 0)
        # but these should
        2.hours.ago.should == Time.new(2012, 6, 25, 23)
        4.hour.ago.should == Time.new(2012, 6, 25, 21)
      }
    end

    it "should wrap backwards a month to locate the day" do
      tt.fixate(2012, 3, 2) {
        4.days.ago.should == Time.new(2012, 2, 27)
        2.days.ago.should == Time.new(2012, 2, 29)
        tt.last(2).days.should == Time.new(2012, 2, 29)
        tt.last(4).days.should == Time.new(2012, 2, 27)
      }
    end

    it "should wrap backwards a month to locate the day in a leap year" do
      tt.fixate(2011, 3, 2) {
        2.days.ago.should == Time.new(2011, 2, 28)
        4.days.ago.should == Time.new(2011, 2, 26)
        tt.last(2).days.should == Time.new(2011, 2, 28)
        tt.last(4).days.should == Time.new(2011, 2, 26)
      }
    end

    it "should wrap backwards more than a month to locate a day" do
      Timetastic.fixate(2012, 6, 15) {
        2.days.ago.should == Time.new(2012, 6, 13)
        15.days.ago.should == Time.new(2012, 5, 31)
        17.days.ago.should == Time.new(2012, 5, 29)
      }
      Timetastic.fixate(2012, 6, 10) {
        29.days.ago.should == Time.new(2012, 5, 12)
        30.days.ago.should == Time.new(2012, 5, 11)
        32.days.ago.should == Time.new(2012, 5, 9)
        64.days.ago.should == Time.new(2012, 4, 7)
      }
    end

    it "should wrap backwards a month to locate the week" do
      tt.fixate(2012, 6, 8) {
        1.week.ago.should == Time.new(2012, 6, 1)
        # this should wrap
        2.weeks.ago.should == Time.new(2012, 5, 25)
        tt.last(2).weeks.should == Time.new(2012, 5, 25)
      }
    end

    it "should wrap backwards a year to locate a month" do
      tt.fixate(2011, 3, 5) {
        # this should wrap
        6.month.ago.should == Time.new(2010, 9, 6, 1)
        3.month.ago.should == Time.new(2010, 12, 5)
        # these shouldn't
        1.month.ago.should == Time.new(2011, 2, 3)
        2.month.ago.should == Time.new(2011, 1, 4)
      }
    end

  end # Backwards wrapping

  describe "Far-off, OOR wrapping" do
    it "should wrap backwards more than a year to locate a month" do
      Timetastic.fixate(2012, 6, 1) {
        10.months.ago.should == Time.new(2011, 8, 6)
        12.months.ago.should == Time.new(2011, 6, 7)
        13.months.ago.should == Time.new(2011, 5, 8)
        18.months.ago.should == Time.new(2010, 12, 8, 23)
        20.months.ago.should == Time.new(2010, 10, 10)
        36.months.ago.should == Time.new(2009, 6, 17)
        48.months.ago.should == Time.new(2008, 6, 22)
        60.months.ago.should == Time.new(2007, 6, 28)
        66.months.ago.should == Time.new(2006, 12, 29, 23)
      }

      Timetastic.fixate(2007, 8, 15) { |t|
        8.months.ago.should == Time.new(2006,12,17, 23)
        19.months.ago.should == Time.new(2006,1,21, 23)
        20.months.ago.should == Time.new(2005,12,22, 23)
      }
    end

    it "should wrap forward more than a month to locate a day" do
      Timetastic.fixate(2012, 6, 15) {
        32.days.ahead.should == Time.new(2012, 7, 17)
        64.days.ahead.should == Time.new(2012, 8, 18)
        65.days.ahead.should == Time.new(2012, 8, 19)
        15.days.ahead.should == Time.new(2012, 6, 30)
        16.days.ahead.should == Time.new(2012, 7, 1)
        90.days.ahead.should == Time.new(2012, 9, 13)
        365.days.ahead.should == Time.new(2013, 6, 15)
        2700.days.ahead.should == Time.new(2019, 11, 5, 23)
      }
    end

    it "should wrap forwards more than a year to locate a month" do
      Timetastic.fixate(2012, 6, 1) {
        6.months.ahead.should == Time.new(2012, 11, 28)
        18.months.ahead.should == Time.new(2013, 11, 22, 23)
        23.months.ahead.should == Time.new(2014, 4, 22)
      }

      Timetastic.fixate(2020, 7, 30) {
        1.months.ahead.should == Time.new(2020, 8, 29)
        14.months.ahead.should == Time.new(2021, 9, 23)
        25.months.ahead.should == Time.new(2022, 8, 19)
      }
    end
  end

  describe "Fixating" do
    it "should fixate using a Time object" do
      Timetastic.fixate(Time.new(2012,1,1)) {
        1.year.ahead.should == Time.new(2013,1,1)
      }
    end

    it "should fixate using a DateTime object" do
      Timetastic.fixate(DateTime.new(2012,1,1)) {
        1.year.ahead.should == Time.new(2013,1,1, 2)
      }
    end

    it "should fixate using integers mapped to date arguments" do
      Timetastic.fixate(2012,1,1) {
        1.year.ahead.should == Time.new(2013,1,1)
      }
    end
  end

  context "Anchoring" do
    before(:all) do
      @ty = Time.now.year
      @tm = Time.now.month
      @td = Time.now.day
      @t  = Timetastic.zero Time.now

      Timetastic.zero_hours = true
    end

    after(:all) do
      Timetastic.zero_hours = false
    end

    it "should anchor the yearly domain" do
      1.year.ahead.should == Time.new(@ty+1,@tm,@td)
      1.year.ahead.should == 1.year.ahead(@t)

      for i in 0..50 do
        i.year.ahead(i.year.ago(@t)).should == @t
        i.year.ahead(Time.new(@ty-i,@tm,@td)).should == @t
      end

      for i in 0..50 do
        i.year.ago(i.year.ahead(@t)).should == @t
        i.year.ago(Time.new(@ty+i,@tm,@td)).should == @t
      end
    end

    it "should anchor the monthly domain" do
      1.month.ahead.should == 1.month.ahead(@t)
      one_month_ahead = 1.month.ahead(@t)

      Timetastic.fixate(@t) do
        1.month.ahead.should == one_month_ahead
      end

      1.month.ahead(1.month.ago(@t)).should == @t
      1.month.ago(1.month.ahead(@t)).should == @t
    end

  end

end