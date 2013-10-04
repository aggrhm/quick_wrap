module QuickWrap

  class ProgressBar < UIView

    def initWithFrame(frame)
      super
      @progress = 0
      @pnl_progress = UIView.new.qw_subview(self)
      return self
    end

    def layoutSubviews
      super
      @pnl_progress.qw_frame 3, 3, self.progress_width, -3
    end

    def set_colors(fg, bg)
      @pnl_progress.backgroundColor = fg
      self.backgroundColor = bg
      self.qw_border fg, 1.0
    end

    def progress=(val)
      val = [val, 1].min
      @progress = val
      @pnl_progress.qw_size self.progress_width, nil
    end

    def progress_width
      (@progress * (self.frame.size.width - 6)).to_i
    end

  end

end
