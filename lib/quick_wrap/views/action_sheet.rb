module QuickWrap

  class ActionSheet
    include Eventable

    def initialize(opts = {}, &block)
      opts[:buttons] ||= []
      @sheet = UIActionSheet.alloc.initWithTitle(opts[:title], delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil, otherButtonTitles: nil)
      @keys = []
      opts[:buttons].each {|b| self.add_button(b, b)}
      block.call(self) if block 
      self.retain
    end

    def add_button(key, title, action=nil, opts={})
      @sheet.addButtonWithTitle(title)
      @keys << {key: key, action: action, title: title}
      @sheet.cancelButtonIndex = @sheet.numberOfButtons - 1 if key == :cancel
      @sheet.destructiveButtonIndex = @sheet.numberOfButtons - 1 if opts[:destructive]
    end

    def title=(val)
      @sheet.title = val
    end

    def actionSheet(actionSheet, clickedButtonAtIndex: buttonIndex)
      #self.trigger(:response, @keys[buttonIndex][:key], buttonIndex)
      action = @keys[buttonIndex][:action]
      action.call if action
      self.autorelease
    end

    def showInView(view)
      @sheet.showInView(view)
    end

    def showFromRect(rect, view)
      @sheet.showFromRect(rect, inView: view, animated: true)
    end

    def sheet
      @sheet
    end

  end

end
