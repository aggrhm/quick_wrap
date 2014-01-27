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
      # get image size
      if self.imageView.image
        img_sz = self.imageView.image.size
        img_rt = img_sz.width.to_f / img_sz.height.to_f
        img_vw = vh * img_rt
        img_vh = vh
      else
        img_sz = CGSizeZero
        img_rt = 0
        img_vw = 0
        img_vh = vh
      end

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
        self.imageView.qw_frame 0, 0, 0, 0
        self.imageView.contentMode = UIViewContentModeScaleAspectFit
      when :image_left_fill
        self.imageView.contentMode = UIViewContentModeScaleAspectFit
        self.imageView.qw_frame 0, 0, img_vw, img_vh
        self.titleLabel.qw_frame img_vw, 0, 0, 0
      when :image_right_fill
        self.imageView.contentMode = UIViewContentModeScaleAspectFit
        self.titleLabel.qw_frame 0, 0, vw - img_vw - 5, 0
        self.titleLabel.qw_text_align :right
        self.imageView.qw_frame vw - img_vw, 0, img_vw, img_vh
      when :image_left_centered_fill
        lbl_vw = self.titleLabel.frame.size.width
        lbl_vh = self.titleLabel.frame.size.height
        spc = vw - img_vw - lbl_vw - 5
        self.imageView.qw_frame spc/2, 0, img_vw, img_vh
        self.titleLabel.qw_frame self.imageView.x_offset + 5, 0, lbl_vw, 0
      when :image_left_centered
        lbl_vw = self.titleLabel.frame.size.width
        lbl_vh = self.titleLabel.frame.size.height
        spc = vw - img_sz.width - lbl_vw - 5
        self.imageView.qw_frame spc/2, (vh - img_sz.height) / 2, img_sz.width, img_sz.height
        self.titleLabel.qw_frame self.imageView.x_offset + 5, (vh - lbl_vh) / 2, lbl_vw, lbl_vh
      when :image_left
        self.imageView.qw_frame 0, 0, 0, 0
        self.imageView.contentMode = UIViewContentModeLeft
        self.titleLabel.qw_frame 0, 0, 0, 0
        self.titleLabel.qw_text_align :center
      when :image_right
        self.imageView.qw_frame 0, 0, 0, 0
        self.imageView.contentMode = UIViewContentModeRight
        self.titleLabel.qw_frame 0, 0, 0, 0
        self.titleLabel.qw_text_align :center
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
