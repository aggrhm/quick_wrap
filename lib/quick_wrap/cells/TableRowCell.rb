module QuickWrap

  class TableRowCell < UICollectionViewCell

    attr_accessor :scope

    def initWithFrame(frame)
      super

      vw = self.contentView.frame.size.width
      vh = self.contentView.frame.size.height

      @img_left = UIImageView.new.qw_subview(self.contentView) {|v|
        v.qw_content_fill
        v.qw_rounded(5)
      }

      @lbl_title = UILabel.new.qw_subview(self.contentView) {|v|
        v.qw_font :reg_16
        v.qw_colors :text
      }

      @btn_arrow = UIButton.new.qw_subview(self.contentView) {|v|
        v.qw_frame_from :top_right, 5, vh / 2 - 8, 15, 15
        v.setImage(UIImage.imageNamed('graphics/icons/icon-arrow-right'), forState: UIControlStateNormal)
      }

      @ln_bottom = UIView.new.qw_subview(self.contentView) {|v|
        v.qw_frame_from :bottom_left, 0, 0, 0, 1
        v.qw_bg :line
      }

      return self
    end

    def from_scope(scope)
      self.scope = scope
      @lbl_title.text = scope[:title]
      self.style_cell
    end

    def style_cell
      vw = self.frame.size.width
      vh = self.frame.size.height
      # styling
      if @scope[:show_image]
        @img_left.qw_frame 5, 5, vh - 10, vh - 10
        @img_left.hidden = false
        @lbl_title.qw_frame_rel :right_of, @img_left, 10, 0, -50, -5
      else
        @img_left.hidden = true
        @lbl_title.qw_frame 10, 5, -50, -5
      end
    end
  end

end
