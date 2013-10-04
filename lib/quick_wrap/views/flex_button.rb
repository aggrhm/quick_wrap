module QuickWrap

  class FlexButton < UIButton

    attr_accessor :flex_style

    def layoutSubviews
      super
      vw = self.size.width
      vh = self.size.height

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

    end
  end
end
