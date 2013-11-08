module QuickWrap

  module Eventable
    # When `event` is triggered the block will execute
    # and be passed the arguments that are passed to
    # `trigger`.
    def on(event, sub=nil, &blk)
      QuickWrap.log "EVENTABLE : adding #{sub.class.to_s} for #{event}"
      sub = self if sub.nil?
      opts = {block: blk, subscriber: sub}
      self.off(event, sub)
      events[event].push(opts)
    end

    def off(event=:all, sub)
      QuickWrap.log "EVENTABLE : releasing #{sub.class.to_s}" if event == :all
      events.each do |action, subs|
        subs.delete_if do |itm|
          if itm[:subscriber].object_id == sub.object_id
            if event== :all
              true
            elsif action == event
              true
            else
              false
            end
          else
            false
          end
        end
      end
    end

    def events
      @events ||= Hash.new { |h,k| h[k] = [] }
    end

    # Trigger an event
    def trigger(event, *args)
      #QuickWrap.log "EVENTABLE : triggered :#{event} on #{self.class.to_s}"
      self.events[event].each do |opts|
        QuickWrap.log "EVENTABLE : handling #{event} for #{opts[:subscriber].class.to_s} (#{args[0].is_a?(Hash) ? 'Hash' : args[0]})"
        opts[:block].call(*args)
      end
    end
  end

end
