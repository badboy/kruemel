require 'time'

def distance_of_time_in_words(from_time, to_time = Time.now, include_seconds = false)
  from_time = from_time.to_time if from_time.respond_to?(:to_time)
  to_time = to_time.to_time if to_time.respond_to?(:to_time)
  distance_in_minutes = (((to_time - from_time).abs)/60).round
  distance_in_seconds = ((to_time - from_time).abs).round

  case distance_in_minutes
  when 0..1
    return distance_in_minutes == 0 ?
               "weniger als eine Minute" :
               ("wenige als %d Minuten" % distance_in_minutes) unless include_seconds

    case distance_in_seconds
    when 0..4   then ("weniger als %d Sekunden" % 5)
    when 5..9   then ("weniger als %d Sekunden" % 10)
    when 10..19 then ("weniger als %d Sekunden" % 10)
    when 20..39 then ("einer halben Minute")
    when 40..59 then ("weniger als einer Minute")
    else             ("einer Minute")
    end

  when 2..44           then ("%d Minuten" % distance_in_minutes)
  when 45..89          then ("etwa einer Stunde")
  when 90..1439        then ("etwa %d Stunden" % (distance_in_minutes.to_f / 60.0).round)
  when 1440..2529      then ("einem Tag")
  when 2530..43199     then ("%d Tagen" % (distance_in_minutes.to_f / 1440.0).round)
  when 43200..57600    then ("etwa einem Monat")
  when 57601..525599   then ("%d Monaten" % (distance_in_minutes.to_f / 43200.0).round)
  else
    distance_in_years           = distance_in_minutes / 525600
    minute_offset_for_leap_year = (distance_in_years / 4) * 1440
    remainder                   = ((distance_in_minutes - minute_offset_for_leap_year) % 525600)
    if remainder < 131400
      ("etwa %d Jahren" % distance_in_years)
    elsif remainder < 394200
      ("mehr als %d Jahren" % distance_in_years)
    else
      ("etwa %d Jahren" % distance_in_years+1)
    end
  end
end
