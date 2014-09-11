module QuickWrap

  TIME_MINUTE = 60
  TIME_HOUR = TIME_MINUTE * 60
  TIME_DAY = TIME_HOUR * 24
  TIME_WEEK = TIME_DAY * 7
  TIME_MONTH = TIME_DAY * 31
  TIME_YEAR = TIME_DAY * 365

  def self.debug=(val)
    @debug = val
  end

  def self.debug?
    @debug ||= false
  end

  def self.log(str)
    puts str if debug?
  end

  def self.can_send_text?
    MFMessageComposeViewController.canSendText
  end

  def self.time_ago_str(input_time)
    test_s = input_time
    now_s = Time.now.utc.to_i
    diff = now_s - test_s

    val = 0
    scale = 'seconds'
    if diff > TIME_YEAR
      val = diff / TIME_YEAR
      scale = 'year'
    elsif diff > TIME_MONTH
      val = diff / TIME_MONTH
      scale = 'month'
    elsif diff > TIME_WEEK
      val = diff / TIME_WEEK
      scale = 'week'
    elsif diff > TIME_DAY
      val = diff / TIME_DAY
      scale = 'day'
    elsif diff > TIME_HOUR
      val = diff / TIME_HOUR
      scale = 'hour'
    elsif diff > TIME_MINUTE
      val = diff / TIME_MINUTE
      scale = 'minute'
    else
      val = diff
      scale = 'second'
    end

    attr = scale + ( (val > 1) ? 's' : '' )

    if scale == 'second' && val < 10
      return "just now"
    else
      return "#{val} #{attr} ago"
    end
  end

  def self.pretty_time_str(time_i)
    now_t = Time.now.localtime
    time_t = Time.at(time_i).localtime
    now_i = now_t.to_i
    diff = now_i - time_i
    fstr = ""

    if diff < TIME_YEAR
      if time_t.yday == now_t.yday
        fstr = "Today"
      elsif diff < TIME_WEEK
        fstr = "%A"
      else
        fstr = "%b %-m"
      end
    else
      fstr = "%b %-m %Y"
    end
    return time_t.strftime("#{fstr}, %l:%M %P")
  end

  def self.label_height(text, width, font, size=nil)
    if font.is_a? Symbol
      fo = AppDelegate::FONT_STYLES[font]
      font = UIFont.fontWithName(fo[0], size: size || fo[1])
    end
    body_h = text.sizeWithFont(font, constrainedToSize: CGSizeMake(width, 1000), lineBreakMode: UILineBreakModeWordWrap).height
  end

  def self.string_attr(attr)
    ret = {}
    attr.each do |key, val|
      case key
      when :color
        ret[NSForegroundColorAttributeName] = AppDelegate::COLORS[val]
      when :font
        f = AppDelegate::FONT_STYLES[val]
        ret[NSFontAttributeName] = UIFont.fontWithName(f[0], size: f[1])
      end
    end

    return ret
  end

  def self.to_json(obj)
    BW::JSON.generate(obj)
  end

  def self.cache
    @cache ||= Hash.new
  end

  def self.pluralize(num, sing, plur)
    if num == 1
      return sing
    else
      return plur
    end
  end

  def self.truncate(str, len=50)
    str.length > len ? "#{str[0..len]}..." : str
  end

  def self.blank?(val)
    val.nil? || val == ""
  end

  def self.color(c)
    if c.is_a?(Symbol)
      AppDelegate::COLORS[c]
    else
      c
    end
  end

  def self.image(c)
    AppDelegate::IMAGES[c]
  end
  def self.image_path(c)
    AppDelegate::IMAGES[c]
  end

  module WeakDelegate
    def delegate=(del)
      @delegate = WeakRef.new(del)
    end
    def delegate
      @delegate
    end
  end

end

QW = QuickWrap
