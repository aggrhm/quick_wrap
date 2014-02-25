module QuickWrap

  class TabViewController < UIViewController

    def viewDidLoad
      super

      @pnl_content = UIView.new.qw_subview(self.view) {|v|
        v.qw_frame 0, 0, 0, 0
      }
    end

    def viewControllers=(ctrs)
      @ctrs = ctrs
    end

    def contentView
      @pnl_content
    end

    def selectedIndex=(idx)
      return if idx == @sel_idx
      old_ctr = self.selectedViewController
      new_ctr = @ctrs[idx]
      if old_ctr
        cycleFromViewController(old_ctr, toViewController: new_ctr)
      else
        addInitialViewController(new_ctr)
      end
      @sel_idx = idx
    end

    def selectedIndex
      @sel_idx
    end

    def selectedViewController
      return nil if @sel_idx.nil?
      @ctrs[@sel_idx]
    end

    private

    def addInitialViewController(new_ctr)
      self.addChildViewController(new_ctr)
      new_ctr.view.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height)
      self.contentView.addSubview(new_ctr.view)
      new_ctr.didMoveToParentViewController(self)
    end

    def cycleFromViewController(old_ctr, toViewController: new_ctr)
      old_ctr.willMoveToParentViewController(nil)
      self.addChildViewController(new_ctr)

      new_ctr.view.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height)
      new_ctr.view.alpha = 0

      self.contentView.addSubview(new_ctr.view)

      UIView.animateWithDuration(0.25,
        animations: lambda {
          new_ctr.view.alpha = 1
          old_ctr.view.alpha = 0
        },
        completion: lambda {|f|
          old_ctr.view.removeFromSuperview
          old_ctr.removeFromParentViewController
          new_ctr.didMoveToParentViewController(self)
        }
      )
    end
  end

end
