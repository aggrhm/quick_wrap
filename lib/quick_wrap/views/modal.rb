module QuickWrap

  class Modal < UIView

    attr_accessor :delegate, :selector, :modalView, :contentView, :headerView, :parent

    include Eventable

    def initWithFrame(frame)
      super
      self.backgroundColor = BW.rgba_color(255, 255, 255, 0.8)
      self.qw_resize :height, :width
      @modal_opts = {}

      #@blur_view = UIView.new.qw_subview(self) {|v|
        #v.qw_blur
      #}

      self.modalView = UIView.new.qw_subview(self) {|v|
        #v.qw_shadow(optimized: false)
        v.backgroundColor = BW.rgb_color(68, 75, 88)
        v.qw_resize :width, :height
      }

      self.headerView = UIView.new.qw_subview(self.modalView) {|v|
        v.backgroundColor = BW.rgb_color(33, 36, 42)
        v.qw_border BW.rgb_color(40, 40, 40), 1.0
      }
        @lbl_hdr_title = UILabel.new.qw_subview(self.headerView) {|v|
          v.textColor = UIColor.whiteColor
          v.backgroundColor = UIColor.clearColor
          v.qw_font 'Avenir-Black', 16
        }

      self.contentView = UIView.new.qw_subview(self.modalView) {|v|
        v.qw_resize :width, :height
      }

      @img_close = UIImageView.new.qw_subview(self.modalView) {|v|
        v.image = UIImage.imageNamed('quick_wrap/close-white')
        v.when_tapped { self.hide }
      }

      return self
    end

    def load_for(parent)
      self.parent = parent
      self.did_load
    end

    def load_for_window
      self.load_for(App.window.subviews[0])
    end

    def title=(title)
      @lbl_hdr_title.text = title
    end

    def set_modal_opts(opts)
      @modal_opts = opts
    end

    def prepare(opts, &block)
      @prepare_opts = opts
      @prepare_block = block
    end

    def layoutInParent
      #cv_h = @prepare_opts[:height] || 100

    end

    def show
      #window = UIApplication.sharedApplication.keyWindow
      self.will_show
      self.alpha = 0.0
      self.parent.addSubview(self)
      UIView.animateWithDuration(0.2,
        animations: lambda {
          self.alpha = 1.0
          @modal_opts[:blur].qw_blur if @modal_opts[:blur]
        },
        completion: lambda {|finished|
          self.did_show
        })
    end

    def hide
      UIView.animateWithDuration(0.2, 
        animations: lambda { self.alpha = 0 },
        completion: lambda {|finished| self.removeFromSuperview })
      @modal_opts[:blur].qw_remove_blur if @modal_opts[:blur]
      self.did_hide
    end

    def will_show
      #self.layoutSubviews
    end

    def did_show

    end

    def did_hide

    end

    def did_load
      #self.qw_frame 0, 0, 0, 0, self.parent
      self.when_tapped { self.hide } unless @modal_opts[:static]
      @img_close.hidden = @modal_opts[:static] == true
      @lbl_hdr_title.hidden = @modal_opts[:hide_header] == true
      #@blur_view.hidden = @modal_opts[:blur] != true

      self.reset_frame
      self.layout_for_parent
    end

    def layoutSubviews
      self.layout_for_parent
    end

    def reset_frame
      self.qw_frame 0, 0, 0, 0, self.parent
    end

    def layout_for_parent
      vh = self.size.height
      vw = self.size.width

      QuickWrap.log "Modal : layoutSubviews"
      ml = @modal_opts[:left] || 5
      mt = @modal_opts[:top] || 5
      mr = @modal_opts[:right] || 5
      mb = @modal_opts[:bottom] || 5

      if !@modal_opts[:height].nil?
        if @modal_opts[:top].nil?
          space = vh - @modal_opts[:height]
          mt = mb = space / 2
        else
          mb = vh - mt - @modal_opts[:height]
        end
      end
      if !@modal_opts[:width].nil?
        space = vw - @modal_opts[:width]
        ml = mr = space / 2
      end

      hide_header = @modal_opts[:hide_header] || true


      #@blur_view.qw_frame 0, 0, 0, 0

      self.modalView.qw_frame ml, mt, -mr, -mb
      mvw = self.modalView.size.width
      self.headerView.frame = CGRectMake(0, 0, mvw, (hide_header ? 0 : 35))
      self.contentView.qw_frame_rel :bottom_of, self.headerView, 0, 0, 0, 0
      @lbl_hdr_title.qw_frame 5, 5, -25, -5
      @img_close.qw_frame mvw - 30, 5, 25, 25
    end

    def show_loading
      QuickWrap.show_loading(self.contentView)
    end

    def hide_loading
      QuickWrap.hide_loading(self.contentView)
    end
  end

  class GridModal < Modal
    def self.createPrompt(del, opts={})
      p = opts[:view].superview || App.window
      b = opts[:view]
      modal = self.new.tap {|v|
        v.delegate = del
        opts[:hide_header] ||= true
        opts[:static] ||= true
        opts[:width] ||= [p.frame.size.width - 10, 500].min
        #QuickWrap.log opts[:width]
        opts[:height] ||= opts[:width]
        opts[:blur] ||= b
        #QuickWrap.log opts[:blur]
        v.set_modal_opts(opts)
        v.load_for(p)
      }
    end

    def did_load
      super
      vw = self.contentView.size.width
      vh = self.contentView.size.height

      self.backgroundColor = UIColor.clearColor
      self.modalView.backgroundColor = BW.rgba_color(0, 0, 0, 0.7)
      self.modalView.qw_rounded 5.0

      @bh = @bw =  (vw / 3).to_i
      @bt = 0
      @bl = 0
      @num_buttons = 0
    end

    def add_button(title, image_path=nil, &block)
      btn = UIView.new.qw_subview(self.contentView) {|v|
        v.qw_frame @bl, @bt, @bw, @bh
        img = UIImageView.new.qw_subview(v) {|img|
          img.qw_frame( ((@bw - 30) / 2).to_i, @bh/2 - 25, 30, 30)
          img.image = UIImage.imageNamed(image_path)
          img.contentMode = UIViewContentModeScaleAspectFit
        }
        lbl = UILabel.new.qw_subview(v) {|lbl|
          lbl.qw_frame 10, @bh-40, -10, 35
          lbl.qw_text_align :center
          lbl.qw_style :label
          lbl.qw_font 'Avenir-Black', 14
          lbl.text = title
          lbl.qw_multiline
        }
        v.when_tapped {
          v.backgroundColor = BW.rgb_color(69, 124, 249)
          self.hide
          block.call if block
        }
      }
      @num_buttons += 1
      @bt += @bh if @num_buttons % 3 == 0
      @bl = (@num_buttons % 3) * @bw
    end
  end

  class TextPromptModal < Modal

    def self.prompt(del, opts)
      p = opts[:view] || App.window
      modal = self.new.tap {|v|
        v.delegate = del
        opts[:hide_header] ||= true
        opts[:static] ||= true
        opts[:height] ||= 120
        opts[:top] ||= p.frame.origin.y
        #opts[:blur] ||= App.window.subviews[-1]
        v.set_modal_opts(opts)
        v.load_for(p)
      }
    end

    def did_load
      super
      vw = self.contentView.size.width
      vh = self.contentView.size.height

      lbl_title = UILabel.new.qw_subview(self.contentView) {|v|
        v.qw_frame 0, 5, vw, 30
        v.qw_font 'Avenir-Black', 12
        v.textAlignment = UITextAlignmentCenter
        v.backgroundColor = UIColor.clearColor
        v.textColor = UIColor.whiteColor
        v.text = @modal_opts[:title]
      }

      @txt_entry = UITextField.new.qw_subview(self.contentView) {|v|
        v.qw_frame 15, lbl_title.y_offset + 5, vw-30, 25
        v.qw_font 'Avenir-Book', 14
        v.backgroundColor = UIColor.whiteColor
        v.textColor = UIColor.blackColor
        v.borderStyle = UITextBorderStyleRoundedRect
        v.clearButtonMode = UITextFieldViewModeWhileEditing
        v.text = @modal_opts[:text]
      }

      btn_cancel = UIButton.buttonWithType(UIButtonTypeCustom).qw_subview(self.contentView) {|v|
        v.qw_frame vw / 2 - 85, vh-40, 80, 40
        v.qw_font 'Avenir-Black', 12
        v.setBackgroundColor(BW.rgb_color(36, 40, 46), forState: UIControlStateNormal)
        v.setTitleColor(UIColor.whiteColor, forState: UIControlStateNormal)
        v.setTitle('Cancel', forState: UIControlStateNormal)
        v.when(UIControlEventTouchUpInside) { self.hide }
      }

      btn_done = UIButton.buttonWithType(UIButtonTypeCustom).qw_subview(self.contentView) {|v|
        v.qw_frame vw / 2 + 5, vh - 40, 80, 40
        v.qw_font 'Avenir-Black', 12
        v.setBackgroundColor(BW.rgb_color(36, 40, 46), forState: UIControlStateNormal)
        v.setTitleColor(UIColor.whiteColor, forState: UIControlStateNormal)
        v.setTitle('OK', forState: UIControlStateNormal)
        v.when(UIControlEventTouchUpInside) { trigger(:response, @txt_entry.text, self) }
      }

    end

    def did_show
      @txt_entry.becomeFirstResponder
    end

  end

end
