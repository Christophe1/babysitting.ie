ActiveSupport::TimeWithZone.class_eval do

  #  Returns time in unified format, eg. 2012-01-15
  #
  def nice_time
    self.strftime('%Y-%m-%d')
  end

end