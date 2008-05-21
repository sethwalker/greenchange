# until we have better localization support for times and dates
module LocalizedTime
  def loc(format = nil)
    if format
      self.strftime(format)
    else
      self
    end
  end
end
class Time 
  include LocalizedTime 
end
class Date
  include LocalizedTime 
end
class DateTime
  include LocalizedTime 
end

