module QuickWrap

  class JobRunner
    include Eventable

    def initialize

      @jobs = []
      @running_job = nil

    end

    def add_to_queue(task_block, job_del, opts)
      job_opts = opts[:job_opts] || {}
      job = Job.new(self)
      job.image = opts[:image]
      job.run_block = task_block
      job.delegate = job_del
      job.opts = job_opts
      @jobs << job

      if @running_job.nil?
        self.run_next
      end

      return job
    end

    def run_next
      if @jobs.empty?
        @running_job = nil
      else
        @running_job = @jobs.shift
        self.trigger :job_starting, @running_job
        @running_job.run
      end
    end

    def job_completed(job)
      self.trigger :job_completed, job
      self.run_next
    end

    def running_job
      @running_job
    end

    def add_view_to(superview, delegate)
      view = JobView.alloc.initWithFrame(CGRectMake(0, 0, superview.size.width, 40))
    end
  end

  class Job
    include Eventable

    attr_accessor :delegate, :image, :progress, :run_block, :runner, :opts

    def initialize(runner)
      self.runner = runner
      self.progress = 0
    end

    def run
      self.trigger(:starting)
      EM.schedule_on_main { self.run_block.call(self) }
    end

    def update_progress(val)
      self.progress = val
      self.trigger(:progress_updated, val)
    end

    def complete
      QuickWrap.log 'Job completed.'
      self.progress = 1
      self.runner.job_completed(self)
      self.trigger(:completed)
    end

    def is_running?
      self.runner.running_job == self
    end

  end

  class JobView < UIView

    attr_accessor :delegate, :job

    DEFAULT_HEIGHT = 60

    def initWithFrame(frame)
      super

      vw = frame.size.width
      vh = frame.size.height

      self.backgroundColor = BW.rgb_color(31, 33, 37)
      self.clipsToBounds = true

      @img_view = UIImageView.new.qw_subview(self) {|v|
        v.qw_frame 5, 5, DEFAULT_HEIGHT-10, DEFAULT_HEIGHT-10
        v.qw_border UIColor.whiteColor, 1.0
      }

      @prog_bar = UIProgressView.new.qw_subview(self) {|v|
      }

      @img_cancel = UIImageView.new.qw_subview(self) {|v|
        v.image = UIImage.imageNamed 'quick_wrap/close-white'
        v.when_tapped {
          self.hide_view
        }
      }
      return self
    end

    def layoutSubviews
      vw = self.size.width
      vh = self.size.height

      @prog_bar.qw_frame_rel :right_of, @img_view, 10, vh/2 - 5, -30, 10
      @img_cancel.qw_frame_rel :right_of, @prog_bar, 5, -5, 20, 20
    end

    def runner=(runner)
      QuickWrap.log "JOBVIEW : setting runner to #{runner.inspect}"
      if !runner.nil?
        @runner = runner
        self.set_job(@runner.running_job)
        @runner.on(:job_starting, self) {|job|
          self.set_job(job)
        }
      else
        @runner.off(:all, self) if @runner
        @runner = nil
      end
    end

    def runner
      @runner
    end

    def set_job(job)
      self.job.off(:all, self) if self.job

      if job.nil?
        return
      end

      self.show_view

      self.job = job
      if self.job.image.is_a? UIImage
        @img_view.image = self.job.image.croppedToSize(@img_view.size)
      else
        @img_view.source_url = self.job.image
        @img_view.load_from_url
      end
      self.set_progress self.job.progress

      job.on(:starting, self) { self.show_view }
      job.on(:completed, self) { self.hide_view }
      job.on(:progress_updated, self) {|val|
        self.set_progress(val)
      }
    end

    def show_view
      QuickWrap.log 'showing job view'
      #UIView.animateWithDuration(0.5, animations: lambda {
      self.qw_size(self.superview.size.width, DEFAULT_HEIGHT)
      #})
    end

    def hide_view
      QuickWrap.log 'hiding job view'
      #UIView.animateWithDuration(0.5, animations: lambda {
      self.qw_size(nil, 0)
      #})
    end

    def set_progress(val)
      @prog_bar.setProgress(val, true)
    end

  end

end
