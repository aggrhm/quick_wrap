module QuickWrap

  class TabView < UIView

    def initWithFrame(frame)
      super

      self.qw_resize :width, :height

      @panes = {}
      return self
    end

    def add_pane(key, view, &block)
      instance = view.new.qw_subview(self, &block)
      @panes[key] = instance
      return instance
    end

    def select_pane(key)
      self.each_pane do |pane|
        pane.hidden = true
      end
      pane = @panes[key]
      pane.hidden = false
      return pane
    end

    def each_pane
      @panes.values.each do |pane|
        yield pane
      end
    end

    def [](key)
      @panes[key]
    end
  end

end
