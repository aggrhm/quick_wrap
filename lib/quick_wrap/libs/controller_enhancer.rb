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

    def observeKeyboard

      @obs_key_show = App.notification_center.observe UIKeyboardWillShowNotification do |notif|
        v = self.is_a?(UIView) ? self : self.view
        key_h = notif.userInfo[UIKeyboardBoundsUserInfoKey].CGRectValue.size.height
        QuickWrap.log "ControllerEnhancer::observeKeyboard : Superview is nil (#{v.inspect} - [#{v.subviews.inspect}])" if v.superview.nil?
        if !v.superview.nil?
          v.qw_size(nil, v.superview.frame.size.height - v.frame.origin.y - key_h)
          self.handle_keyboard_event(:shown)
        end
      end

      @obs_key_hide = App.notification_center.observe UIKeyboardWillHideNotification do |notif|
        v = self.is_a?(UIView) ? self : self.view
        key_h = notif.userInfo[UIKeyboardBoundsUserInfoKey].CGRectValue.size.height
        if !v.superview.nil?
          v.qw_size(nil, v.superview.frame.size.height - v.frame.origin.y)
          self.handle_keyboard_event(:hidden)
        end
      end

    end

    def unobserveKeyboard
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
      ctr = ctr_cls.alloc.initWithNibName(nil, bundle:nil)
      ctr.delegate = self if ctr.respond_to? 'delegate='
      block.call(ctr) if block
      self.navigationController.pushViewController(ctr, animated:true)
    end

  end

end
