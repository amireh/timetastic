## Overview

Whenever I'm working with an ORM other than ActiveRecord, I miss the relative date locating
functionality like `1.day.ago` and `5.years.ahead` so I mashed up Timetastic to provide
those features to any Ruby script.

Every feature directly depends and deals with Ruby `Time` implementation. While I'm unaware of
any gotchas or limitations, it's probably good to know.

## Locating relative times

The locators are either "past" or "future" ones, all relative to today's date. The available
time domains are: hours, days, weeks, months, and years.

* `5.days.ago` or `1.day.ago` (singular and plural versions are available for every domain)
* `6.months.ahead` or `1.year.hence`

It properly accomodates wrapping when it's necessary. Knowing that June is 30 days long:

```ruby
Timetastic.fixate(2012, 6, 30) {
  1.day.ahead # => 2012-07-01 00:00:00 +0300
}

Timetastic.fixate(2012, 6, 30, 20) {
  4.hours.ahead # => 2012-07-01 00:00:00 +0300
}
```

The wrapping functionality works for all domains, and in both directions; forward into future dates
and backwards to past ones. It's also smart enough to take leap years into account:

```ruby
# 2012 is not a leap year, February is 29 days long
Timetastic.fixate(2012, 3, 1) {
  1.day.ago # => 2012-02-29 00:00:00 +0200
}

# 2011 is a leap year, February is 28 days long
Timetastic.fixate(2011, 3, 1) {
  1.day.ago # => 2011-02-28 00:00:00 +0200
}
```

Some module methods are available that produce *anchored* dates; the beginning
of intervals like months, years, or days. These are useful when, for example,
you need to retrieve all records created since a given month, or year, regardless of the
current day, or month, respectively.

* `Timetastic.last.month`: points to the start of last month
* `Timetastic.last(5).years`: points to the start of the 5th year before the current one
* `Timetastic.coming.month` or `Timetastic.next.month`: point to the start of the coming month

You can also change the time _anchor_ which is by default set to `Time.now` by calling `fixate`:

```ruby
Timetastic.fixate(2012, 6, 1) {
  1.month.ahead # => 2012-07-01 00:00:00 +0300
  3.days.ago    # => 2012-05-29 00:00:00 +0300
}
```

It's also possible to do it at the time of the selection. All methods accept a `relative_to` argument:

```ruby
1.month.ahead(Time.new(2012, 6, 1))            # => 2012-07-01 00:00:00 +0300
Timetastic.last(1, Time.new(2012, 6, 1)).month # => 2012-05-01 00:00:00 +0300
```

But as you can see, the interface to the per-method fixating isn't very sexy.

### Really far away times

Need to reach a month that's further behind than last year? It's also good:

```ruby
    Timetastic.fixate(2012, 6, 1) {
      10.months.ago.should == Time.new(2011, 8, 1)
      13.months.ago.should == Time.new(2011, 5, 1)
      36.months.ago.should == Time.new(2009, 6, 1)
      48.months.ago.should == Time.new(2008, 6, 1)
      60.months.ago.should == Time.new(2007, 6, 1)
      66.months.ago.should == Time.new(2006, 12, 1)

      # or go forward
      23.months.ahead.should == Time.new(2014, 5, 1)
      24.months.ahead.should == Time.new(2014, 6, 1)
    }
```

Timetastic will handle the proper wrapping of dates,
it should never throw an Out of Range argument error or so.

## Legal stuff

`Timetastic` the gem is licensed under the MIT terms like PageHub is.

```text
Copyright (c) 2012 Ahmad Amireh

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
OR OTHER DEALINGS IN THE SOFTWARE.
```

