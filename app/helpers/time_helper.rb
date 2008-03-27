module TimeHelper

  # Our goal here it to automatically display the date in the way that
  # makes the most sense. Elusive, i know. If an array of times is passed in
  # we display the newest one. 
  # Here are the current options:
  #   4:30PM    -- time was today
  #   Wednesday -- time was within the last week.
  #   Mar/7     -- time was in the current year.
  #   Mar/7/07  -- time was in a different year.
  # The date is then wrapped in a label, so that if you hover over the text
  # you will see the full details.
  def friendly_date(*times)
    return nil unless times.any?

    time  = times.compact.max
    local = to_local(time)
    today = local_now.to_date
    date  = local.to_date
    
    if date == today
      str = local.strftime("%I:%M<span style='font-size: 80%'>%p</span>")
    elsif today > date and (today-date) < 7
      str = local.strftime("%A")
    else
      #str = date.loc('%m.%d.%Y')
      str = date.to_s('%m.%d.%Y')
    end
    "<label title='#{ full_time(time) }'>#{str}</label>"
  end
  
  # formats a time, in full detail
  # for example: Sunday July/3/2007 2:13PM
  def full_time(time)
    time = to_local time
    #'%s %s %s %s' % [time.loc('%A'), time.loc('%d/%b/%Y'), time.loc('%I:%M'), time.period.abbreviation]
    '%s %s %s' % [time.strftime('%A'), time.strftime('%d/%b/%Y'), time.strftime('%I:%M')]
  end

  def to_local(time)
    TzTime.zone.utc_to_local(time)
  end
    
  def to_utc(time)
    TzTime.zone.local_to_utc(time)
  end

  def local_now
    TzTime.zone.now
  end

  def after_local_day_start?(utc_time)
    local_now.at_beginning_of_day < to_local(utc_time)
  end
  
  def after_local_yesterday_start?(utc_time)
    local_now.yesterday.at_beginning_of_day < to_local(utc_time)
  end

  def after_local_week_start?(utc_time)
    (local_now.at_beginning_of_day - 7.days) < to_local(utc_time)
  end
  
end

