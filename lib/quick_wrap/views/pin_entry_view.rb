module QuickWrap

  class PinEntryView < UIView
    include QuickWrap::Eventable

    attr_accessor :pin

    def initWithFrame(frame)
      super

      @pin = ""

      @lbl_title = UILabel.new.qw_subview(self) {|v|
        v.qw_frame_set 5, 5, -5, 20
        v.qw_text_align :center
        v.qw_font :reg_12
        v.qw_colors :text
      }

      @pnl_dots = UIView.new.qw_subview(self) {|v|
        v.qw_frame_set :bottom_of, @lbl_title, 0, 5, -5, 20
      }

      @dots = []
      4.times do |i|
        dot = UIView.new.qw_subview(@pnl_dots) {|v|
          v.qw_rounded 5
          v.qw_border AppDelegate::COLORS[:text], 1.0
        }
        @dots << dot
      end

      @nums = []
      [1,2,3,4,5,6,7,8,9,0].each do |i|
        num = UIButton.new.qw_subview(self) {|v|
          v.qw_font :reg, 22
          v.setTitle("#{i}", forState: UIControlStateNormal)
          v.setTitleColor(AppDelegate::COLORS[:text], forState: UIControlStateNormal)
          v.setBackgroundImage(UIImage.from_color(AppDelegate::COLORS[:bg_mid]), forState: UIControlStateHighlighted)
          v.tag = i
          v.when(UIControlEventTouchUpInside) do
            self.enter_number(i)
          end
        }
        @nums << num
      end

      @btn_del = UIButton.new.qw_subview(self) {|v|
        v.qw_font :reg, 18
        v.setTitle("DEL", forState: UIControlStateNormal)
        v.setTitleColor(AppDelegate::COLORS[:text], forState: UIControlStateNormal)
        v.setBackgroundImage(UIImage.from_color(AppDelegate::COLORS[:bg_mid]), forState: UIControlStateHighlighted)
        v.when(UIControlEventTouchUpInside) do
          self.delete_number
        end
      }

      return self
    end

    def layoutSubviews
      vw = self.frame.size.width
      vh = self.frame.size.height
      dot_size = 10

      @lbl_title.qw_reframe
      @pnl_dots.qw_reframe

      dx = @pnl_dots.frame.size.width / 2 - 25
      nw = vw / 3
      nh = nw * 2 / 3

      @dots.each do |dot|
        dot.qw_frame dx, 0, 10, 10
        dx += 15
      end

      cy = @pnl_dots.y_offset + 20
      @nums.each_with_index do |num, idx|
        val = num.tag.to_i
        if val != 0
          col = idx % 3
          row = (idx / 3)
          x = nw * col
          y = nh * row
        else
          x = nw * 1
          y = nh * 3
        end
        num.qw_frame x, cy + y, nw, nh
      end

      @btn_del.qw_frame nw * 2, cy + nh * 3, nw, nh

    end

    def title=(val)
      @lbl_title.text = val
    end

    def enter_number(num)
      @pin += "#{num}"
      self.update_dots
      if @pin.length == 4
        self.check_pin
      end
    end

    def delete_number
      if @pin.length > 0
        @pin = @pin[0..-2]
      end
      self.update_dots
    end

    def clear
      @pin = ""
      self.update_dots
    end

    def update_dots
      @dots.each_with_index do |dot, idx|
        if @pin.length >= idx+1
          dot.qw_bg :text
        else
          dot.qw_bg :clear
        end
      end
    end

    def check_pin
      self.trigger "response", @pin
    end

  end

end
