# %a - The abbreviated weekday name (``Sun'')
# %A - The  full  weekday  name (``Sunday'')
# %b - The abbreviated month name (``Jan'')
# %B - The  full  month  name (``January'')
# %c - The preferred local date and time representation
# %d - Day of the month (01..31)
# %H - Hour of the day, 24-hour clock (00..23)
# %I - Hour of the day, 12-hour clock (01..12)
# %j - Day of the year (001..366)
# %m - Month of the year (01..12)
# %M - Minute of the hour (00..59)
# %p - Meridian indicator (``AM''  or  ``PM'')
# %S - Second of the minute (00..60)
# %U - Week  number  of the current year,
#         starting with the first Sunday as the first
#         day of the first week (00..53)
# %W - Week  number  of the current year,
#         starting with the first Monday as the first
#         day of the first week (00..53)
# %w - Day of the week (Sunday is 0, 0..6)
# %x - Preferred representation for the date alone, no time
# %X - Preferred representation for the time alone, no date
# %y - Year without a century (00..99)
# %Y - Year with century
# %Z - Time zone name
# %% - Literal ``%'' character
# 
#  t = Time.now
#  t.strftime("Printed on %m/%d/%Y")   #=> "Printed on 04/09/2003"
#  t.strftime("at %I:%M%p")            #=> "at 08:56AM"

# Rails formats:
# :db           => "%Y-%m-%d %H:%M:%S",
# :number       => "%Y%m%d%H%M%S",
# :time         => "%H:%M",
# :short        => "%d %b %H:%M",
# :long         => "%B %d, %Y %H:%M",
# :long_ordinal => lambda { |time| time.strftime("%B #{ActiveSupport::Inflector.ordinalize(time.day)}, %Y %H:%M") },
# :rfc822       => lambda { |time| time.strftime("%a, %d %b %Y %H:%M:%S #{time.formatted_offset(false)}") }

# time.iso8601
# time.xmlschema

formats = {
  num: "%y%m%d_%H%M%S",
  humane: ->(val) { val.year == Time.now.year ? val.strftime("%b #{val.day} %H:%M") : val.to_s(:rus_zone) },
  short_date: "%d.%m.%Y %H:%M:%S",
  rus_zone: "%d.%m.%Y %H:%M:%S %Z",
  rus_usec: ->(val) { val.strftime("%d.%m.%Y %H:%M:%S.#{'%06d' % val.usec} %Z") }
}
Time::DATE_FORMATS.update(formats)
Date::DATE_FORMATS.update(formats)
