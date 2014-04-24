module QuickWrap

  class SectionScrollBar < UIView

    attr_accessor :delegate

    def initWithFrame(frame)
      super

      @markers = []
      @marker_height = 15

      self.qw_bg :white

      @pnl_markers = UIView.new.qw_subview(self) {|v|
        v.qw_frame 0, 0, 0, 0
        v.qw_resize :width, :height
        v.qw_bg :clear
      }

      @pnl_touch = UIView.new.qw_subview(self) {|v|
        v.qw_frame 0, 0, 0, 0
        v.qw_resize :width, :height
        v.qw_bg :clear
      }

      # handle tap and pan
      @pnl_touch.when_tapped {|rec|
        pt = rec.locationInView(self)
        #QW.log "Now touched at (#{pt.inspect})"
        self.select_marker_at_point(pt)
      }
      @pnl_touch.when_panned {|rec|
        pt = rec.locationInView(self)
        #QW.log "Now panned at (#{pt.inspect})"
        self.select_marker_at_point(pt)
      }

      return self
    end

    def build_with_letters
      @markers.each {|v| v.removeFromSuperview}

      @markers = ("A".."Z").collect do |ltr|
        UILabel.new.qw_subview(@pnl_markers) {|v|
          v.qw_colors :text_light
          v.qw_font :bold, 10
          v.qw_text_align :center
          v.text = ltr
        }
      end
    end

    def layoutSubviews
      vw = self.frame.size.width
      vh = self.frame.size.height

      mph = @markers.length * @marker_height
      ch = (vh - mph) / 2

      @pnl_markers.qw_reframe
      @markers.each do |v|
        v.qw_frame 0, ch, 0, @marker_height
        ch += @marker_height
      end
    end

    def select_marker(marker)
      self.delegate.handle_scroll_bar_marker_gesture(marker.text, :tapped, marker) if self.delegate.respond_to?(:handle_scroll_bar_marker_gesture)
    end

    def select_marker_at_point(pt)
      pt.x = 5
      @markers.each do |v|
        if CGRectContainsPoint(v.frame, pt)
          #QW.log "Selecting #{v.text} at #{v.frame.origin.inspect}"
          self.select_marker(v)
          break
        end
      end
    end

  end

end
