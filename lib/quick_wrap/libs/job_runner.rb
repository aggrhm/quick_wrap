module QuickWrap

  class JobRunner
    include Eventable

    def initialize(opts={})
      @options = {
        max_concurrent: 10,
        allow_queuing: true
      }
      @options.merge!(opts)
      @jobs = []
    end

    def jobs
      @jobs
    end

    def jobs_with_state(state)
      @jobs.select {|j| j.state == state}
    end

    def job_count(state)
      self.jobs_with_state(state).length
    end

    def has_jobs?
      @jobs.any? {|j| j.state != :done }
    end

    def add_to_queue(task_block, opts)
      # prepare job
      job_opts = opts[:job_opts] || {}
      job = Job.new(self)
      job.image = opts[:image]
      job.run_block = task_block
      job.delegate = opts[:delegate]
      job.opts = job_opts

      # add if any spots for running or can queue
      if self.job_count(:running) < @options[:max_concurrent] || @options[:allow_queuing]
        @jobs << job
        self.process_jobs
        return job
      else
        return nil
      end
    end

    def process_jobs
      return if @jobs.empty?

      rjs = self.jobs_with_state(:running)
      wjs = self.jobs_with_state(:waiting)
      while ( (self.job_count(:running) < @options[:max_concurrent]) && (self.job_count(:waiting) > 0) ) do
        # run any waiting jobs
        nj = self.jobs_with_state(:waiting).first
        self.trigger :job_starting, nj
        nj.bg_id = UIApplication.sharedApplication.beginBackgroundTaskWithExpirationHandler lambda {
          UIApplication.sharedApplication.endBackgroundTask(nj.bg_id) if nj.bg_id
          nj.state = :done
        }
        nj.run
      end
    end

    def clean_jobs
      @jobs.delete_if {|j| j.state == :done}
    end

    def job_completed(job)
      self.trigger :job_completed, job
      self.clean_jobs
      self.process_jobs
      UIApplication.sharedApplication.endBackgroundTask(job.bg_id) if job.bg_id
    end

    def latest_running_job
      self.jobs_with_state(:running).last
    end

    def add_view_to(superview, delegate)
      view = JobView.alloc.initWithFrame(CGRectMake(0, 0, superview.size.width, 40))
    end
  end

  class Job
    include Eventable
    include WeakDelegate

    attr_accessor :image, :progress, :run_block, :runner, :opts, :state, :bg_id

    def initialize(runner)
      self.runner = runner
      self.progress = 0
      self.state = :waiting
    end

    def run
      self.state = :running
      self.trigger(:starting)
      EM.schedule_on_main { self.run_block.call(self) }
    end

    def update_progress(val)
      self.progress = val
      self.trigger(:progress_updated, val)
    end

    def complete
      QuickWrap.log 'Job completed.'
      self.update_progress(1)
      self.state = :done
      self.trigger(:completed)
      self.runner.job_completed(self)
    end

    def is_running?
      self.state == :running
    end

  end

  class JobView < UIView
    include WeakDelegate

    attr_accessor :job

    DEFAULT_HEIGHT = 60

    def initWithFrame(frame)
      super

      vw = frame.size.width
      vh = frame.size.height

      self.qw_bg :white
      self.clipsToBounds = true

      @img_view = UIImageView.new.qw_subview(self) {|v|
        v.qw_frame 5, 5, DEFAULT_HEIGHT-10, DEFAULT_HEIGHT-10
        v.qw_border AppDelegate::COLORS[:bg_view], 1.0
        v.qw_content_fill
      }

      @prog_bar = UIProgressView.new.qw_subview(self) {|v|
        v.progressTintColor = AppDelegate::COLORS[:green]
      }

      @img_cancel = UIImageView.new.qw_subview(self) {|v|
        v.image = UIImage.imageNamed 'quick_wrap/close-gray'
        v.alpha = 0.5
        v.when_tapped {
          self.hide_view
        }
      }

      @ln_btm = UIView.new.qw_subview(self) {|v|
        v.qw_frame_set :bottom_left, 0, 0, 0, 1
        v.qw_bg :bg_mid
        v.qw_resize :top
      }

      return self
    end

    def layoutSubviews
      vw = self.size.width
      vh = self.size.height

      @prog_bar.qw_frame_rel :right_of, @img_view, 10, vh/2 - 5, -30, 10
      @img_cancel.qw_frame_rel :right_of, @prog_bar, 5, -10, 20, 20
      @ln_btm.qw_reframe
    end

    def runner=(runner)
      QuickWrap.log "JOBVIEW(#{self.object_id}) : setting runner to #{runner.inspect}"
      if !runner.nil?
        @runner = runner
        self.set_job(@runner.latest_running_job) if @runner.has_jobs?
        @runner.on(:job_starting, self) {|job|
          self.set_job(job)
        }
        @runner.on(:job_completed, self) {|job|
          self.hide_view if !@runner.has_jobs?
        }
      else
        @runner.off(:all, self) if @runner
        @job.off(:all, self) if @job
        @runner = nil
        self.hide_view
      end
    end

    def runner
      @runner
    end

    def imageView
      @img_view
    end

    def progressView
      @prog_bar
    end

    def set_job(job)
      return if job.nil?
      QW.log "JOBVIEW: updating job view"
      # cleanup
      self.job.off(:all, self) if self.job

      self.show_view

      self.job = job
      if self.job.image.is_a? UIImage
        @img_view.image = self.job.image
      else
        @img_view.source_url = self.job.image
        @img_view.load_from_url
      end
      self.set_progress self.job.progress

      #job.on(:starting, self) { self.show_view }
      job.on(:completed, self) { 
        job.off(:all, self)
        # pick next running job unless there is one waiting
        self.set_job(@runner.latest_running_job) unless @runner.job_count(:waiting) > 0
      }
      job.on(:progress_updated, self) {|val|
        self.set_progress(val)
      }
    end

    def show_view
      QuickWrap.log "showing job view #{self.object_id}"
      #UIView.animateWithDuration(0.5, animations: lambda {
      self.qw_size(self.superview.size.width, DEFAULT_HEIGHT)
      #})
    end

    def hide_view
      QuickWrap.log "hiding job view #{self.object_id}"
      #UIView.animateWithDuration(0.5, animations: lambda {
      self.qw_size(nil, 0)
      #})
    end

    def set_progress(val)
      @prog_bar.setProgress(val, true)
    end

  end

end
