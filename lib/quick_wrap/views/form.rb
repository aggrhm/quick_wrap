module QuickWrap

  class Form < UIScrollView

    attr_accessor :elements, :selected_element, :inset, :spacing

    def add(type, key, opts={}, &block)
      @inset ||= UIEdgeInsetsMake(0, 0, 0, 0)
      el_cls = case type
      when :textfield
        FormTextField
      when :text
        FormTextView
      when :datetime
        FormDateTimePicker
      when :button
        FormButton
      when :image
        FormImage
      when :label
        FormLabel
      end

      # determine frame
      width = opts[:width] || 0
      width -= @inset.right if width <= 0
      height = opts[:height] || 40
      el = el_cls.alloc.initWithFrame(CGRectZero)

      # auto position
      first_el = self.elements.empty?
      if !first_el
        if !opts[:bottom_of] && !opts[:right_of]
          last_el = self.elements.values.last
          opts[:bottom_of] = last_el.key
        end
      end
      spacing = opts[:spacing] || self.spacing || 10

      # add to view
      el.qw_subview(self) {|v|
        if opts[:bottom_of]
          v.qw_frame_rel :bottom_of, self.elements[opts[:bottom_of]], 0, spacing, width, height
        elsif opts[:right_of]
          v.qw_frame_rel :right_of, self.elements[opts[:right_of]], spacing, 0, width, height
        else
          v.qw_frame @inset.left, @inset.top, width, height
        end
      }
      el.build_view
      el.key = key
      el.process_options(opts)
      block.call(el) if block
      self.elements[key] = el
      self.update_size
    end

    def elements
      @elements ||= {}
    end

    def [](key)
      self.elements[key].value
    end

    def update_size
      heights = self.elements.values.collect{|el| el.y_offset}
      widths = self.elements.values.collect{|el| el.x_offset}
      self.contentSize = CGSizeMake(widths.max, heights.max)
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
          v.qw_frame_from :bottom_left, 0, 0, 0, 200
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

    def show_asset_picker(element)
      QuickWrap::Camera.display_picker(from_rect: element.bounds, view: self, delegate: App.delegate.root_ctr) do |result|
        if result[:original_image]
          element.value = result[:original_image]
        end
      end
    end

    def select_next_element
      idx = self.elements.values.index(self.selected_element)
      el = self.elements.values[idx+1]
      if el
        self.handle_element_selected(el)
      end
    end

  end

  class FormElement < UIView

    attr_accessor :options, :key

    def build_view

      @panel_bg = UIView.new.qw_subview(self) {|v|

      }

      @img_icon = UIImageView.new.qw_subview(self) {|v|
        #v.qw_frame 5, 5, 25, 25
      }

      @lbl_title = UILabel.new.qw_subview(self) {|v|
        v.qw_resize :width
      }

      self.when_tapped {self.form.handle_element_selected(self)}

    end

    def process_options(opts)
      self.options = opts
      self.qw_style opts[:style] || self.default_style
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

    def default_style
      :form_element
    end

  end

  class FormLabel < FormElement

    def default_style
      :form_element_label
    end

  end

  class FormTextField < FormElement

    def build_view
      super
      @txt_view = UITextField.new.qw_subview(self) {|v|
        v.delegate = self
        v.clearButtonMode = UITextFieldViewModeWhileEditing
        v.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter
        v.returnKeyType = UIReturnKeyDone
      }
    end

    def process_options(opts)
      super
      case opts[:type]
      when :email
        self.text_view.keyboardType = UIKeyboardTypeEmailAddress
      when :password
        self.text_view.secureTextEntry = true
      end
    end

    def text_view
      @txt_view
    end

    def handle_blur
      @txt_view.resignFirstResponder
    end

    def handle_focus
      @txt_view.becomeFirstResponder
    end

    def textFieldDidBeginEditing(tv)
      self.form.handle_element_selected(self)
    end

    def textFieldShouldReturn(tv)
      if tv.returnKeyType == UIReturnKeyNext
        self.form.select_next_element
      else
        tv.resignFirstResponder
      end
    end

    def value
      @txt_view.text
    end

    def value=(val)
      super
      @txt_view.text = val
    end

    def default_style
      :form_element_text
    end
  end

  class FormTextView < FormElement

    def build_view
      super
      @txt_view = UITextView.new.qw_subview(self) {|v|
        v.delegate = self
      }
    end

    def text_view
      @txt_view
    end

    def handle_blur
      @txt_view.resignFirstResponder
    end

    def handle_focus
      @txt_view.becomeFirstResponder
    end

    def textViewDidBeginEditing(tv)
      self.form.handle_element_selected(self)
    end

    def value
      @txt_view.text
    end

    def value=(val)
      super
      @txt_view.text = val
    end

    def default_style
      :form_element_text
    end
  end

  class FormButton < FormElement
    def build_view
      super
      self.subviews.each {|v| v.hidden = true}
      @btn = QuickWrap::FlexButton.new.qw_subview(self) {|v|
        v.qw_frame 0, 0, 0, 0
        v.qw_resize :width, :height
      }
    end

    def process_options(opts)
      @btn.qw_style opts[:style] || self.default_style
      @btn.setTitle(opts[:title], forState: UIControlStateNormal)
      @btn.when(UIControlEventTouchUpInside) {
        opts[:action].call
      }
    end

    def default_style
      :button_gray
    end
  end

  class FormDateTimePicker < FormElement

    def build_view
      super
      @lbl_view = UILabel.new.qw_subview(self)
    end

    def label_view
      @lbl_view
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

    def default_style
      :form_element_date
    end
  end

  class FormImage < FormElement

    def build_view
      super

      @img_view = UIImageView.new.qw_subview(self) {|v|
        v.qw_content_fill
        v.when_tapped {
          self.prompt_select_picture
        }
      }
    end

    def image_view
      @img_view
    end

    def value
      @value
    end

    def value=(val)
      super
      @value = val
      if @value.is_a? UIImage
        @img_view.image = @value
      else
        @img_view.source_url = @value
        @img_view.load_from_url
      end
    end

    def has_new_image?
      @value.is_a? UIImage
    end

    def prompt_select_picture
      p = QuickWrap::ActionSheet.new
      p.add_button :library, "Choose from library...", lambda {
        self.form.show_asset_picker(self)
      }
      p.add_button :cancel, "Cancel"
      p.showInView(App.window)
    end

    def default_style
      :form_element_image
    end

  end

end
