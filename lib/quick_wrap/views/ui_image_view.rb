class UIImageView
  include QuickWrap::Eventable

  attr_accessor :source_url, :_url, :do_fade

  def load_from_url(url=nil, &block)
    if url.nil?
      url = self.source_url
    else
      self.source_url = url
    end

    if url.nil?
      self.image = nil
    elsif url.match(/^http[s]?:\/\/.*/)
      # load async
      self.image = nil
      #BW::HTTP.get(url) do |response|
        #self.alpha = 0
        #img = UIImage.alloc.initWithData(response.body)
        #img = block.call(img) if block
        #self.image = img
        #UIView.beginAnimations('fadeIn', context: nil)
        #UIView.setAnimationDuration(0.5)
        #self.alpha = 1.0
        #UIView.commitAnimations
      #end
      trigger :state, :loading
      SDWebImageManager.sharedManager.downloadWithURL(url, options:0, progress:nil, completed: lambda{|img, error, cacheType, finished|
        if img
          # check if url still the same
          return if url != self.source_url
          @_url = url
          self.alpha = 0
          img = block.call(img) if block
          self.image = img
          if cacheType == SDImageCacheTypeNone || self.do_fade
            UIView.beginAnimations('fadeIn', context: nil)
            UIView.setAnimationDuration(0.5)
            self.alpha = 1.0
            UIView.commitAnimations
          else
            self.alpha = 1.0
          end
          trigger :state, :loaded
        end
      })
    else
      img = UIImage.imageNamed(url)
      @_url = url
      img = yield(img) if block
      self.image = img
      trigger :state, :loaded
    end
  end

  def load_from_url(url, croppedTo: targetSize)
    self.load_from_url(url) do |img|
      img.qw_crop(targetSize) if img
    end
  end

  def load_cropped_to(targetSize)
    self.load_from_url(self.source_url, croppedTo: targetSize)
  end

  def load_cropped
    self.load_from_url(self.source_url, croppedTo: self.size)
  end

  def load_from_url(url, stretchedTo: targetSize)
    self.load_from_url(url) do |img|
      img.stretchedToSize(targetSize) if img
    end
  end

  def has_image?
    !self.image.nil?
  end

end
