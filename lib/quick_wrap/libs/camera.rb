module QuickWrap

  module Camera

    def self.display_picker(opts={}, &block)
      ctr_pick = UIImagePickerController.alloc.init
      ctr_pick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary
      ctr_pick.mediaTypes = [KUTTypeImage]
      if Device.iphone?
        pc = opts[:delegate] || App.window.rootViewController
        v = pc.presentViewController(ctr_pick, animated: true, completion: lambda{})
        ctr_pick.delegate = QuickWrap::Camera::PickerDelegate.new({picker: v}, block)
      elsif Device.ipad?
        v = UIPopoverController.alloc.initWithContentViewController(ctr_pick)
        ctr_pick.delegate = QuickWrap::Camera::PickerDelegate.new({popover: v}, block)
        v.delegate = ctr_pick.delegate
        #ctr_pick.delegate.popover = v
        v.presentPopoverFromRect(opts[:from_rect], inView: opts[:view], permittedArrowDirections: UIPopoverArrowDirectionAny, animated: true)
      end
      return v
    end

    class PickerDelegate

      def initialize(opts={}, callback)
        @opts = opts
        @callback = callback
        self.retain
      end

      def imagePickerControllerDidCancel(picker)
        @callback.call({error: 1000})
        self.dismiss
      end

      def imagePickerController(picker, didFinishPickingMediaWithInfo: info)
        ret = {}
        info.each{|k,v|
          ret[k.gsub("UIImagePickerController", "").underscore.to_sym] = v
        }
        @callback.call(ret)
        self.dismiss
      end

      def dismiss
        if Device.iphone?
          @opts[:picker].dismissViewControllerAnimated(true, completion: lambda{})
        elsif Device.ipad?
          @opts[:popover].dismissPopoverAnimated(true)
          @opts[:popover] = nil
        end
        self.autorelease
      end

      def popoverControllerDidDismissPopover(popover)
        self.autorelease
      end

    end

  end

end
