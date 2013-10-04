puts "ACTIONSHEET LOADING"
module QuickWrap

  class ActionSheet
    include Eventable

    def initialize(opts = {}, &block)
      opts[:buttons] ||= []
      @sheet = UIActionSheet.alloc.initWithTitle(opts[:title], delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil, otherButtonTitles: nil)
      @keys = []
      opts[:buttons].each {|b| self.add_button(b, b)}
      block.call(@sheet) if block 
      self.retain
    end

    def add_button(title, key, opts={})
      @sheet.addButtonWithTitle(title)
      @keys << key
      @sheet.cancelButtonIndex = @sheet.numberOfButtons - 1 if key == :cancel
      @sheet.destructiveButtonIndex = @sheet.numberOfButtons - 1 if opts[:destructive]
    end

    def title=(val)
      @sheet.title = val
    end

    def actionSheet(actionSheet, clickedButtonAtIndex: buttonIndex)
      self.trigger(:response, @keys[buttonIndex], buttonIndex)
      self.autorelease
    end

    def showInView(view)
      @sheet.showInView(view)
    end

    def sheet
      @sheet
    end

  end

end
