module QuickWrap

  class FontIcon

    def self.awesome(name, opts={size: 24})
      @fa_key_map ||= begin
        ret = {}
        FAKFontAwesome.allIcons.each {|key, val| ret[val] = key}
        ret
      end
      pn = name.gsub(/(\-[a-z])/){|m| m[1].upcase}
      key = @fa_key_map[pn]
      #puts "#{pn} - #{key}"
      icon = FAKFontAwesome.iconWithCode(key, size: opts[:size])
      if opts[:color]
        icon.addAttribute(NSForegroundColorAttributeName, value: opts[:color])
      end
      return icon
    end

    def self.awesome_image_view(name, opts)
      icon = self.awesome(name, opts)
      UIImageView.alloc.initWithFrame(CGRectMake(0, 0, opts[:size], opts[:size])).tap {|v|
        v.image = icon.imageWithSize(CGSizeMake(opts[:size], opts[:size]))
        v.contentMode = UIViewContentModeScaleAspectFit
      }
    end

  end

end
