module QuickWrap

  class TableRowCell < UICollectionViewCell

    attr_accessor :scope

    def initWithFrame(frame)
      super

      vw = self.contentView.frame.size.width
      vh = self.contentView.frame.size.height

      @img_left = UIImageView.new.qw_subview(self.contentView) {|v|
        v.qw_frame 5, 5, vh - 10, vh - 10
        v.qw_content_fill
        v.qw_rounded(5)
      }

      @lbl_title = UILabel.new.qw_subview(self.contentView) {|v|
        v.qw_font :reg_16
        v.qw_colors :text
      }

      @btn_arrow = UIButton.new.qw_subview(self.contentView) {|v|
        v.qw_frame_set :top_right, 5, 0, 30, 0
        v.setImage(UIImage.imageNamed('graphics/icons/icon-arrow-right'), forState: UIControlStateNormal)
      }

      @ln_bottom = UIView.new.qw_subview(self.contentView) {|v|
        v.qw_frame_set :bottom_left, 0, 0, 0, 1
        v.qw_bg :line
      }

      return self
    end

    def imageView
      @img_left
    end

    def titleLabel
      @lbl_title
    end

    def layoutSubviews
      super
      @btn_arrow.qw_reframe
      @ln_bottom.qw_reframe
    end

    def from_scope(scope)
      self.scope = scope
      @lbl_title.text = scope[:title]
      img = scope[:image]
      if img
        if img.is_a? UIImage
          @img_left.image = img
        elsif img.is_a? String
          @img_left.source_url = img
          @img_left.load_from_url
        elsif img.is_a? Symbol
          @img_left.image = UIImage.from_sym(img)
        end
      end
      self.style_cell
    end

    def style_cell
      vw = self.frame.size.width
      vh = self.frame.size.height
      # styling
      if @scope[:image]
        @img_left.hidden = false
        @img_left.qw_reframe
        @lbl_title.qw_frame_rel :right_of, @img_left, 10, 0, -30, -5
      else
        @img_left.hidden = true
        @lbl_title.qw_frame 10, 5, -30, -5
      end

      @btn_arrow.hidden = @scope[:arrow] == false
    end
  end

end
