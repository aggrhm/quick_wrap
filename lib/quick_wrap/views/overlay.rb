module QuickWrap

  module Overlay

    module ClassMethods
      def notify(text, type=:success, opts={})
        QuickWrap.log(text) 
        if type == :error
          SVProgressHUD.showErrorWithStatus(text)
        else
          SVProgressHUD.showSuccessWithStatus(text)
        end
      end

      def show_loading(view, text=nil, opts={})
        if text.nil?
          #DejalBezelActivityView.activityViewForView(view, withLabel: '')
          SpinnerView.addToView(view)
        else
          #DejalBezelActivityView.activityViewForView(view, withLabel: text)
          SpinnerView.addToView(view)
        end
      end

      def hide_loading(view=nil)
        #DejalBezelActivityView.removeView
        SpinnerView.removeFromView(view)
      end

      def confirm(title, message, &handler)
        opts = {}
        opts[:title] = title
        opts[:message] = message
        opts[:buttons] = ['Yes', 'No']
        opts[:on_click] = lambda {|alert|
          handler.call(alert.clicked_button.title.downcase.to_sym)
        }
        alert = BW::UIAlertView.new(opts)
        alert.show
      end
    end

    extend ClassMethods

    def self.included(base)
      base.extend ClassMethods
    end

    ## CUSTOM LOADING VIEW
    class SpinnerView < UIView

      def self.addToView(view, title=nil)
        return if view.nil?
        sv = SpinnerView.alloc.initWithFrame(view.bounds)
        view.addSubview(sv)
      end

      def self.removeFromView(view)
        view.subviews.select{|sv| sv.is_a? SpinnerView}.each{|sv| sv.removeFromSuperview}
      end

      def initWithFrame(frame)
        super
        self.qw_bg :white_fade
        #self.setBackground
        self.qw_resize :width, :height
        @spinner = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray).qw_subview(self) {|v|
          v.qw_resize :top, :bottom, :left, :right
          v.center = self.center
          v.startAnimating
        }
        return self
      end

      def layoutSubviews
        super
        self.frame = self.superview.bounds
        @spinner.center = self.center
      end

      def setBackground
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 1)
        num_locations = 2
        locations = Pointer.new(:float, 2)
        locations[0] =  0.0
        locations[1] = 1.0
        components = Pointer.new(:float, 8)
        components[0] = 0.4
        components[1] = 0.4
        components[2] = 0.4
        components[3] = 0.8
        components[4] = 0.1
        components[5] = 0.1
        components[6] = 0.1
        components[7] = 0.5
        myColorspace = CGColorSpaceCreateDeviceRGB()
        myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, num_locations)
        myRadius = (self.bounds.size.width*0.8)/2
        CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, self.center, 0, self.center, myRadius, KCGGradientDrawsAfterEndLocation)
        image = UIGraphicsGetImageFromCurrentImageContext()
        #CGColorSpaceRelease(myColorspace)
        #CGGradientRelease(myGradient)
        UIGraphicsEndImageContext()
        bg = UIImageView.alloc.initWithImage(image)
        bg.alpha = 0.7
        self.addSubview(bg)
      end
      
    end

  end

  include Overlay

end
