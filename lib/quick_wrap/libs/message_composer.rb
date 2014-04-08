module QuickWrap

  class MessageComposer

    def self.compose_text_message(opts, ctr, &block)
      opts[:type] = :text
      cmp = self.new(opts, &block)
      cmp.presentFromController(ctr)
    end

    def self.compose_email(opts, ctr, &block)
      opts[:type] = :email
      cmp = self.new(opts, &block)
      cmp.presentFromController(ctr)
    end

    def initialize(opts, &block)
      @options = opts
      @callback = block
      type = @options[:type]
      if type == :email
        prepare_email
      elsif type == :text
        prepare_text
      end
    end

    def presentFromController(ctr)
      ctr.presentViewController(@ctr, animated: true, completion: nil)
    end

    def messageComposeViewController(controller, didFinishWithResult: result)
      @callback.call(result)
      self.autorelease
    end

    def mailComposeController(controller, didFinishWithResult: result, error: error)
      @callback.call(result)
      self.autorelease
    end

    private

    def prepare_text
      @ctr = MFMessageComposeViewController.alloc.init
      @ctr.messageComposeDelegate = self
      @ctr.recipients = @options[:recipients]
      @ctr.body = body
      self.retain
    end

    def prepare_email
      @ctr = MFMailComposeViewController.alloc.init
      @ctr.mailComposeDelegate = self
      @ctr.setSubject(@options[:subject])
      @ctr.setToRecipients(@options[:to_recipients])
      @ctr.setMessageBody(@options[:body], isHTML: @options[:is_html] || false)
      self.retain
    end


  end

end
