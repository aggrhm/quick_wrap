module QuickWrap

  module MenuCapable

    def close_and_show_nav_for(ctr)
      self.viewDeckController.closeLeftViewBouncing lambda {|vdc|
        self.show_nav_for(ctr)
      }
    end

    def show_nav_for(ctr)
      new_ctr = ctr.alloc.initWithNibName(nil, bundle:nil)
      nav_ctr = UINavigationController.alloc.initWithRootViewController(new_ctr)
      nav_ctr.navigationBar.setBackgroundImage(UIImage.imageNamed('ocean/menubar.png'), forBarMetrics:UIBarMetricsDefault)
      self.viewDeckController.centerController = nav_ctr
    end

  end

end
