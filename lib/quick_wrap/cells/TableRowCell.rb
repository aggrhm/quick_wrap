module QuickWrap

  class TableRowCell < UICollectionViewCell

    attr_accessor :scope

    def initWithFrame(frame)
      super

      vw = self.contentView.frame.size.width
      vh = self.contentView.frame.size.height

      @lbl_title = UILabel.new.qw_subview(self.contentView) {|v|
        v.qw_frame 10, 10, -50, -10
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
    end
  end

end
