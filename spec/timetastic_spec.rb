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
        1.month.hence.should == Time.new(2012, 11, 26)
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
        1.month.ahead.should == Time.new(2012, 1, 5)
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
        6.month.ago.should == Time.new(2010, 9, 5)
        3.month.ago.should == Time.new(2010, 12, 5)
        # these shouldn't
        1.month.ago.should == Time.new(2011, 2, 5)
        2.month.ago.should == Time.new(2011, 1, 5)
      }
    end

  end # Backwards wrapping

  describe "Far-off, OOR wrapping" do
    it "should wrap backwards more than a year to locate a month" do
      Timetastic.fixate(2012, 6, 1) {
        10.months.ago.should == Time.new(2011, 8, 1)
        12.months.ago.should == Time.new(2011, 6, 1)
        13.months.ago.should == Time.new(2011, 5, 1)
        18.months.ago.should == Time.new(2010, 12, 1)
        20.months.ago.should == Time.new(2010, 10, 1)
        36.months.ago.should == Time.new(2009, 6, 1)
        48.months.ago.should == Time.new(2008, 6, 1)
        60.months.ago.should == Time.new(2007, 6, 1)
        66.months.ago.should == Time.new(2006, 12, 1)
      }

      Timetastic.fixate(2007, 8, 15) { |t|
        8.months.ago.should == Time.new(2006,12,15)
        19.months.ago.should == Time.new(2006,1,15)
        20.months.ago.should == Time.new(2005,12,15)

        # 30 years backwards
        for i in 1..30 do
          (i * -12).months.ahead.should == Time.new(t.year - i, t.month, t.day)
        end
      }
    end

    it "should wrap forwards more than a year to locate a month" do
      Timetastic.fixate(2012, 6, 1) {
        6.months.ahead.should == Time.new(2012, 12, 1)
        18.months.ahead.should == Time.new(2013, 12, 1)
        20.months.ahead.should == Time.new(2014, 2, 1)
        23.months.ahead.should == Time.new(2014, 5, 1)
        24.months.ahead.should == Time.new(2014, 6, 1)
      }

      Timetastic.fixate(2020, 7, 30) {
        for i in 1..5 do
          i.months.ahead.should == Time.new(2020, 7 + i, 30)
        end

        6.months.ahead.should == Time.new(2021, 1, 30)
        7.months.ahead.should == Time.new(2021, 3, 2)
        14.months.ahead.should == Time.new(2021, 9, 30)
        25.months.ahead.should == Time.new(2022, 8, 30)

        # 30 years onwards
        for i in 1..30 do
          (i * 12).months.ahead.should == Time.new(2020 + i, 7, 30)
        end

      }
    end
  end

end