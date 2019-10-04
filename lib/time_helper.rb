class TimeHelper
  MINUTES_IN_THREE_QUARTERS_YEAR = 394200
  MINUTES_IN_QUARTER_YEAR = 131400
  MINUTES_IN_YEAR = 525600

  def self.distance_of_time_in_words(from_time, to_time = Time.now)
    from_time = normalize_distance_of_time_argument_to_time(from_time)
    to_time = normalize_distance_of_time_argument_to_time(to_time)

    from_time, to_time = to_time, from_time if from_time > to_time
    distance_in_minutes = ((to_time - from_time) / 60.0).round
    distance_in_seconds = (to_time - from_time).round
    
    case distance_in_minutes
    when 0..1
      case distance_in_seconds
      when 0..4   then "less than 5 seconds"
      when 5..9   then "less than 10 seconds"
      when 10..19 then "less than 20 seconds"
      when 20..39 then "half a minute"
      when 40..59 then "less than 1 minute"
      else             "1 minute"
      end

    when 2...45           then "#{distance_in_minutes} minutes"
    when 45...90          then "about 1 hour"
      # 90 mins up to 24 hours
    when 90...1440        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
      # 24 hours up to 42 hours
    when 1440...2520      then "1 day"
      # 42 hours up to 30 days
    when 2520...43200     then "#{(distance_in_minutes.to_f / 1440.0).round} days"
      # 30 days up to 60 days
    when 43200...86400    then "about #{(distance_in_minutes.to_f / 43200.0).round} months"
      # 60 days up to 365 days
    when 86400...525600   then "#{(distance_in_minutes.to_f / 43200.0).round} months"
    else
      from_year = from_time.year
      from_year += 1 if from_time.month >= 3
      to_year = to_time.year
      to_year -= 1 if to_time.month < 3
      leap_years = (from_year > to_year) ? 0 : (from_year..to_year).count { |x| Date.leap?(x) }
      minute_offset_for_leap_year = leap_years * 1440
      minutes_with_offset = distance_in_minutes - minute_offset_for_leap_year
      remainder                   = (minutes_with_offset % MINUTES_IN_YEAR)
      distance_in_years           = (minutes_with_offset.div MINUTES_IN_YEAR)
      if remainder < MINUTES_IN_QUARTER_YEAR
        "about #{distance_in_years} years"
      elsif remainder < MINUTES_IN_THREE_QUARTERS_YEAR
        "over #{distance_in_years} years"
      else
        "almost #{distance_in_years + 1} years"
      end
    end
  end

  private

  def self.normalize_distance_of_time_argument_to_time(value)
    if value.is_a?(Numeric)
      Time.at(value)
    elsif value.respond_to?(:to_time)
      value.to_time
    else
      raise ArgumentError, "#{value.inspect} can't be converted to a Time value"
    end
  end
end