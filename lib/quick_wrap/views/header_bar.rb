module QuickWrap

  class HeaderBar < UIView

    def initWithFrame(frame)
      super

      #self.backgroundColor = BW.rgb_color(255, 255, 255)
      #self.qw_shadow(optimized: false)
      self.qw_resize :width

      @lbl_title = UILabel.new.qw_subview(self) {|v|
        v.textColor = AppDelegate::COLORS[:text]
        v.backgroundColor = UIColor.clearColor
        v.qw_font 'Avenir-Black', 18
      }

      @img_icon = UIImageView.new.qw_subview(self) {|v|
        v.contentMode = UIViewContentModeScaleAspectFit
        #v.on(:loaded, self) {self.layoutSubviews}
      }

      @lbl_subtitle = UILabel.new.qw_subview(self) {|v|
        v.textColor = UIColor.whiteColor
        v.backgroundColor = UIColor.clearColor
        v.qw_font 'Avenir-Book', 12
        v.qw_text_align :right
      }

      return self
    end

    def layoutSubviews
      vw = self.size.width
      vh = self.size.height
      if self.has_image?
        @lbl_title.qw_frame 35, 5, 0, -5
        @img_icon.qw_frame 5, 10, 25, -10
      else
        @lbl_title.qw_frame 10, 5, 0, -5
        @img_icon.frame = CGRectZero
      end
      @lbl_subtitle.qw_frame_from :bottom_right, 5, 0, 150, 15
    end

    def title=(title)
      @lbl_title.text = title
    end

    def subtitle=(subtitle)
      @lbl_subtitle.text = subtitle
    end

    def image=(img)
      @img_icon.source_url = img
      @img_icon.load_from_url
    end

    def has_image?
      !@img_icon.image.nil?
    end

    def title_label
      @lbl_title
    end

    def add_button(title, action, opts={}, &block)
      vw = self.size.width
      vh = self.size.height
      opts[:width] ||= 100
      opts[:style] ||= :button_gray
      btn = UIButton.buttonWithType(UIButtonTypeCustom).qw_subview(self) {|v|
        v.qw_frame vw - (opts[:width] + 7), 5, opts[:width], vh - 10
        v.qw_resize :left, :height
        v.qw_style opts[:style]
        v.setTitle(title, forState: UIControlStateNormal)
        v.when(UIControlEventTouchUpInside) {action.call}
      }
      block.call(btn) if block
    end

  end

end
