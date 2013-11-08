module QuickWrap

  class FlexButton < UIButton

    attr_accessor :flex_style

    def initWithFrame(frame)
      super

      @spinner = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray).qw_subview(self) {|v|
        v.qw_frame 0, 0, 0, 0
      }

      return self
    end

    def layoutSubviews
      super
      vw = self.size.width
      vh = self.size.height

      @spinner.qw_frame 0, 0, 0, 0

      case self.flex_style
      when :vertical
        self.imageView.qw_frame 10, 10, -10, -30
        self.imageView.contentMode = UIViewContentModeScaleAspectFit
        self.titleLabel.qw_frame 0, vh - 20, 0, 20
        self.titleLabel.qw_text_align :center
      when :image
        self.imageView.qw_resize :width, :height
        self.imageView.qw_frame 10, 10, -10, -10
        self.imageView.contentMode = UIViewContentModeScaleAspectFit
      when :image_fill
        self.imageView.qw_resize :width, :height
        self.imageView.qw_frame 3, 3, -3, -3
        self.imageView.contentMode = UIViewContentModeScaleAspectFit
      when :image_left
        self.imageView.qw_resize :width, :height
        self.imageView.qw_frame 10, 5, 100, -5
        self.imageView.contentMode = UIViewContentModeLeft
      end

      self.imageView.hidden = @is_loading
      self.titleLabel.hidden = @is_loading
      @spinner.hidden = !@is_loading

    end

    def is_loading=(val)
      @is_loading = val
      val ?  @spinner.startAnimating : @spinner.stopAnimating
      self.layoutSubviews
    end

  end
end
