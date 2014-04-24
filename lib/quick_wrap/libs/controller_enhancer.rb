module QuickWrap

  module ControllerEnhancer

    module ClassMethods

      def observe_keyboard
        include QuickWrap::ControllerEnhancer::KeyboardObserver
      end

    end


    module KeyboardObserver
      def viewDidAppear(animated)
        super
        self.observeKeyboard
      end

      def viewDidDisappear(animated)
        super
        self.unobserveKeyboard
      end
    end

    def self.included(base)
      #base.send :extend, ClassMethods
      base.send :include, QuickWrap::Eventable
    end

    def observe_keyboard

      v = self.is_a?(UIView) ? self : self.view

      v.qw_size(nil, v.superview.frame.size.height - App.delegate.app_state[:keyboard][:height] - v.frame.origin.y) unless v.superview.nil?

      @obs_key_show = App.notification_center.observe UIKeyboardWillShowNotification do |notif|
        key_h = notif.userInfo[UIKeyboardBoundsUserInfoKey].CGRectValue.size.height
        QuickWrap.log "ControllerEnhancer::observeKeyboard : Superview is nil (#{v.inspect} - [#{v.subviews.inspect}])" if v.superview.nil?
        if !v.superview.nil?
          v.qw_size(nil, v.superview.frame.size.height - v.frame.origin.y - key_h)
          self.handle_keyboard_event(:shown)
        end
      end

      @obs_key_hide = App.notification_center.observe UIKeyboardWillHideNotification do |notif|
        key_h = notif.userInfo[UIKeyboardBoundsUserInfoKey].CGRectValue.size.height
        if !v.superview.nil?
          v.qw_size(nil, v.superview.frame.size.height - v.frame.origin.y)
          self.handle_keyboard_event(:hidden)
        end
      end

    end

    def unobserve_keyboard
      App.notification_center.unobserve(@obs_key_show)
      App.notification_center.unobserve(@obs_key_hide)
    end

    def handle_keyboard_event(event)

    end

    def scroll_to_bottom(scroll_view)
      offset = scroll_view.contentSize.height - scroll_view.size.height
      scroll_view.setContentOffset([0, offset], animated: true)
    end

    def push_controller(ctr_cls, &block)
      ctr = ctr_cls.alloc.init
      ctr.delegate = self if ctr.respond_to? 'delegate='
      block.call(ctr) if block
      self.navigationController.pushViewController(ctr, animated:true)
    end

    def textFieldShouldReturn(tf)
      if tf.returnKeyType == UIReturnKeyDone
        tf.resignFirstResponder
      end
    end

    def show_loading
      QuickWrap.show_loading(self.view)
    end

    def hide_loading
      QuickWrap.hide_loading(self.view)
    end

  end

  module DelegateEnhancer

    def self.included(base)
      base.send :include, QuickWrap::Eventable
    end

    def observe_keyboard

      @obs_key_show = App.notification_center.observe UIKeyboardWillShowNotification do |notif|
        key_h = notif.userInfo[UIKeyboardBoundsUserInfoKey].CGRectValue.size.height
        self.app_state[:keyboard][:shown] = true
        self.app_state[:keyboard][:height] = key_h
        App.delegate.trigger 'app.keyboard.toggle', key_h
      end

      @obs_key_hide = App.notification_center.observe UIKeyboardWillHideNotification do |notif|
        key_h = notif.userInfo[UIKeyboardBoundsUserInfoKey].CGRectValue.size.height
        self.app_state[:keyboard][:shown] = false
        self.app_state[:keyboard][:height] = 0
        App.delegate.trigger 'app.keyboard.toggle', 0
      end

    end

    def app_state
      @app_state ||= {
        keyboard: {shown: false, height: 0},
        orientation: nil
      }
    end

    def observe_rotation
      @obs_rot = App.notification_center.observe UIDeviceOrientationDidChangeNotification do |notif|
        self.app_state[:orientation] = notif.orientation
        App.delegate.trigger 'app.orientation.changed', notif.orientation
      end
    end
    

  end

end
