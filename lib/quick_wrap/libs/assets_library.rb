module QuickWrap

  class AssetsLibrary


    def self.instance
      @instance ||= ALAssetsLibrary.alloc.init
    end

    def self.group_types
      {camera_roll: 16}
    end
    
    def self.each_group(types, &block)
      al = self.instance
      @enum_done = false
      blk_using = lambda {|group, stop|
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
      al.enumerateGroupsWithTypes(types, usingBlock: blk_using, failureBlock: blk_fail)

    end

    def list_groups(types, &block)
      al = self.instance
      groups = []
      blk_using = lambda {|group, stop|
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
      al.enumerateGroupsWithTypes(types, usingBlock: blk_using, failureBlock: blk_fail)
    end

    def self.each_asset(opts, &block)
      opts[:groups] = [:camera_roll]

      blk_using = lambda {|asset, index, stop|
        if !asset.nil?
          ret = AssetWrapper.new(asset)
          block.call ret
        end
      }

      self.each_group(opts[:groups]) do |group|
        og = group.original
        og.setAssetsFilter ALAssetsFilter.allPhotos
        og.enumerateAssetsUsingBlock(blk_using)
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

      def image
        rep = @original.defaultRepresentation
        UIImage.imageWithCGImage(rep.fullResolutionImage, scale: rep.scale, orientation: rep.orientation)
      end

    end 

  end if defined?(ALAssetsLibrary)

end
