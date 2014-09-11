module QuickWrap

  class OptionModal < Modal

    def self.createPrompt(del, opts={})
      p = opts[:view].superview || App.window
      b = opts[:view]
      modal = self.new.qw_subview(p) {|v|
        v.qw_frame_set 0, 0, 0, 0
        v.delegate = del
        #QuickWrap.log opts[:width]
        #opts[:height] ||= opts[:width]
        opts[:blur] ||= b
        #QuickWrap.log opts[:blur]
        v.set_modal_opts(opts)
      }
    end

    def configure
      super
      @buttons = []
      self.qw_bgcolor 40, 50, 56, 0.2
      self.modalView.qw_bg :white
      self.modalView.qw_rounded 5.0
    end

    def layout_modal
      bh = 40
      mh = bh * @buttons.length
      mt = (self.frame.size.height - mh) / 2
      self.modalView.qw_frame_set 40, mt, -40, mh
    end

    def build_view
      super
      vw = self.contentView.size.width
      vh = self.contentView.size.height
    end

    def add_button(title, opts, &block)
      bt = @buttons.length * 40
      btn = UIView.new.qw_subview(self.contentView) {|v|
        v.qw_frame_set 0, bt, 0, 40
        img_view = UIImageView.new.qw_subview(v) {|img|
          img.qw_frame_set(15, 8, 24, 24)
          if opts[:image]
            img.image = opts[:image]
          elsif opts[:icon]
            img.image = FontIcon.awesome(opts[:icon], {size: 24, color: QW.color(:text)}).imageWithSize(CGSizeMake(24, 24))
          end
          img.contentMode = UIViewContentModeScaleAspectFit
        }
        lbl = UILabel.new.qw_subview(v) {|lbl|
          lbl.qw_frame_set 60, 0, -20, 0
          lbl.qw_font :bold, 12
          lbl.qw_colors :text
          lbl.text = title.upcase
        }
        v.when_tapped {
          v.backgroundColor = BW.rgb_color(69, 124, 249)
          lbl.qw_colors :white
          self.hide
          block.call if block
        }
      }
      @buttons << btn
    end

    def layoutSubviews
      super
      @buttons.each do |b|
        b.qw_reframe
        b.subviews.each {|v| v.qw_reframe}
      end
    end

    def did_hide
      super
      self.removeFromSuperview
    end

  end

end
