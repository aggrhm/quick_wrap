module QuickWrap

  class Form < UIScrollView

    attr_accessor :elements, :selected_element, :inset

    def add(type, key, opts={})
      @inset ||= UIEdgeInsetsMake(0, 0, 0, 0)
      el_cls = case type
      when :text
        FormTextView
      when :datetime
        FormDateTimePicker
      when :button
        FormButton
      end

      # determine frame
      width = opts[:width] || (self.frame.size.width - @inset.right - @inset.left)
      height = opts[:height] || 40
      el = el_cls.alloc.initWithFrame(CGRectMake(0, 0, width, height))
      el.build_view
      el.process_options(opts)
      self.elements[key] = el
      el.qw_subview(self) {|v|
        if opts[:bottom_of]
          v.qw_frame_rel :bottom_of, self.elements[opts[:bottom_of]], 0, opts[:spacing] || 10, width, height
        elsif opts[:right_of]
          v.qw_frame_rel :right_of, self.elements[opts[:right_of]], opts[:spacing] || 10, 0, width, height
        else
          v.qw_frame @inset.left, @inset.top, width, height
        end
      }
      self.update_size
    end

    def elements
      @elements ||= {}
    end

    def update_size
      heights = self.elements.values.collect{|el| el.y_offset}
      widths = self.elements.values.collect{|el| el.x_offset}
      self.contentSize = CGSizeMake(heights.max, widths.max)
    end

    def handle_element_selected(element)
      self.elements.values.each do |el|
        el.handle_blur unless el == element
      end
      element.handle_focus
      self.selected_element = element
    end

    def show_date_picker(date_val, mode=UIDatePickerModeDateTime)
      if @picker.nil?
        @picker = UIDatePicker.new.qw_subview(self) {|v|
          v.qw_frame_from :bottom_left, 0, 0, 0, 250
          v.addTarget(self, action: :handle_date_picker_changed, forControlEvents: UIControlEventValueChanged)
        }
      else
        @picker.hidden = false
      end

      @picker.date = NSDate.dateWithTimeIntervalSince1970(date_val)
      @picker.datePickerMode = mode
    end

    def hide_date_picker
      @picker.hidden = true if @picker
    end

    def handle_date_picker_changed
      self.selected_element.value = @picker.date.timeIntervalSince1970.to_i
    end

  end

  class FormElement < UIView

    attr_accessor :options

    def initWithFrame(frame)
      super

      @panel_bg = UIView.new.qw_subview(self) {|v|

      }

      @img_icon = UIImageView.new.qw_subview(self) {|v|
        #v.qw_frame 5, 5, 25, 25
      }

      @lbl_title = UILabel.new.qw_subview(self) {|v|
        v.qw_resize :width
      }

      self.when_tapped {self.form.handle_element_selected(self)}

      return self
    end

    def process_options(opts)
      self.options = opts
      self.qw_style opts[:style]
      @img_icon.image = UIImage.imageNamed(opts[:icon]) if opts[:icon]
      @lbl_title.text = opts[:title] if opts[:title]
    end

    def handle_focus

    end

    def handle_blur

    end

    def form
      self.superview
    end

    def title_label
      @lbl_title
    end

    def bg_panel
      @panel_bg
    end

    def value

    end

    def value=(val)
      self.options[:on_change].call(val) if self.options[:on_change]
    end

  end

  class FormTextView < FormElement

    def build_view
      @txt_view = UITextView.new.qw_subview(self) {|v|
      }
    end

    def text_view
      @txt_view
    end

    def process_options(opts)
      super
    end

    def handle_blur
      @txt_view.resignFirstResponder
    end

    def value
      @txt_view.text
    end

    def value=(val)
      super
      @txt_view.text = val
    end
  end

  class FormButton < FormElement
    def build_view
      self.subviews.each {|v| v.hidden = true}
      @btn = QuickWrap::FlexButton.new.qw_subview(self) {|v|
        v.qw_frame 0, 0, 0, 0
        v.qw_resize :width, :height
      }
    end

    def process_options(opts)
      @btn.qw_style opts[:style]
      @btn.setTitle(opts[:title], forState: UIControlStateNormal)
      @btn.when(UIControlEventTouchUpInside) {
        opts[:action].call
      }
    end
  end

  class FormDateTimePicker < FormElement

    def build_view
      @lbl_view = UILabel.new.qw_subview(self) {|v|
        v.backgroundColor = UIColor.clearColor
        v.textColor = UIColor.blackColor
      }
    end

    def layoutSubviews
      super
      @lbl_view.qw_frame 40, 5, -5, -5
    end

    def process_options(opts)
      super
      @lbl_view.qw_font *opts[:font] if opts[:font]
    end

    def handle_focus
      picker = self.form.show_date_picker(self.value, self.options[:mode])
    end

    def handle_blur
      self.form.hide_date_picker
    end

    def value
      @value
    end

    def value=(val)
      super
      @value = val
      case self.options[:mode]
      when UIDatePickerModeDateAndTime, nil
        @lbl_view.text = Time.at(@value).strftime("%B %-d, %Y  %l:%M %p")
      when UIDatePickerModeDate
        @lbl_view.text = Time.at(@value).strftime("%B %-d, %Y")
      when UIDatePickerModeTime
        @lbl_view.text = Time.at(@value).strftime("%l:%M %p")
      end
    end
  end

end
