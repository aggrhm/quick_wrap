module QuickWrap

  class AssetsLibrary

    puts "ALASSETSLIBRARY FOUND : DEFINING ASSETSLIBRARY"


    def self.instance
      @instance ||= ALAssetsLibrary.alloc.init
    end

    def self.group_types
      {camera_roll: 16}
    end
    
    def self.each_group(types, &block)
      al = self.instance
      @enum_done = false
      handler = lambda {|group, stop|
        if !group.nil?
          QuickWrap.log 'Processing group'
          ret = AssetGroupWrapper.new(group)
          block.call ret
        else
          @enum_done = true
        end
      }
      blk_fail = lambda {|error|
      }
      types = types.map{|type| self.group_types[type]}.reduce{|memo, val| memo | val}
      al.enumerateGroupsWithTypes(types, usingBlock: handler, failureBlock: blk_fail)

    end

    def list_groups(types, &block)
      al = self.instance
      groups = []
      handler = lambda {|group, stop|
        if !group.nil?
          ret = AssetGroupWrapper.new(group)
          groups << ret
        else
          block.call(groups)
        end
      }
      blk_fail = lambda {|error|
      }
      types = types.map{|type| self.group_types[type]}.reduce{|memo, val| memo | val}
      al.enumerateGroupsWithTypes(types, usingBlock: handler, failureBlock: blk_fail)
    end

    def self.each_asset(opts, &block)
      opts[:groups] = [:camera_roll]
      opts[:limit] ||= 50

      al = self.instance

      handler = lambda {|asset, index, stop|
        if !asset.nil?
          ret = AssetWrapper.new(asset)
          block.call ret
        end
      }

      self.each_group(opts[:groups]) do |group|
        og = group.original
        og.setAssetsFilter ALAssetsFilter.allPhotos
        num_assets = og.numberOfAssets

        if num_assets > opts[:limit]
          si = num_assets - opts[:limit]
          num = opts[:limit]
        else
          si = 0
          num = num_assets
        end
        index_range = NSIndexSet.indexSetWithIndexesInRange(NSMakeRange( si, num))
        og.enumerateAssetsAtIndexes(index_range, options: NSEnumerationReverse, usingBlock: handler)
      end
    end

    def self.list_assets(opts)
      assets = []
      self.each_asset(opts) do |asset|
        assets << asset
      end
    end

    def self.find_asset(url, &block)
      al = self.instance
      blk_result = lambda {|asset|
        block.call asset ? AssetWrapper.new(asset) : nil
      }
      blk_fail = lambda {|error|

      }
      al.assetForURL(url, resultBlock: blk_result, failureBlock: blk_fail)
    end

    def self.save_image(img, &block)
      al = self.instance
      al.writeImageToSavedPhotosAlbum(img.CGImage, orientation: img.imageOrientation, completionBlock: lambda {|url, error|
        if error
          block.call(nil)
        else
          block.call(url)
        end
      })
    end

    def self.save_image_from_url(url, &block)
      SDWebImageManager.sharedManager.downloadWithURL(url, options: (SDWebImageRetryFailed | SDWebImageRefreshCached), progress:nil, completed: lambda{|img, error, cacheType, finished|
        if img
          self.save_image(img, &block)
        else
          QW.log(error.localizedDescription) unless error.nil?
          block.call(nil)
        end
      })
    end

    class AssetGroupWrapper
      def initialize(group)
        @original = group
      end

      def name
        self.original.valueForProperty(ALAssetsGroupPropertyName)
      end

      def original
        @original
      end
    end

    class AssetWrapper
      def initialize(asset)
        @original = asset
      end

      def original
        @original
      end

      def thumbnail_image
        UIImage.imageWithCGImage(@original.thumbnail)
      end

      def url
        @original.defaultRepresentation.url unless @original.defaultRepresentation.nil?
      end

      def image(opts={})
        rep = @original.defaultRepresentation
        opts[:scale] ||= rep.scale
        UIImage.imageWithCGImage(rep.fullResolutionImage, scale: opts[:scale], orientation: rep.orientation)
      end

      def full_screen_image
        rep = @original.defaultRepresentation
        UIImage.imageWithCGImage(rep.fullScreenImage)
      end

      def jpeg_data
        rep = @original.defaultRepresentation
        sz = rep.size
        buf = Pointer.new(:char, sz)
        num_bytes = rep.getBytes(buf, fromOffset: 0, length: sz, error: nil)
        if num_bytes > 0
          return NSData.dataWithBytes(buf, length: sz)
        else
          return nil
        end
      end

    end 

  end if defined?(ALAssetsLibrary)

end
