class UIImage

  def self.load_from_url(url)
    if url.match(/^http[s]?:\/\/.*/)
      UIImage.alloc.initWithData(NSData.dataWithContentsOfURL(NSURL.URLWithString(url)))
    else
      UIImage.imageNamed(url)
    end
  end

  def self.addTransparentBorder(image)
    imageRrect = CGRectMake(0, 0, image.size.width, image.size.height)
    UIGraphicsBeginImageContext( imageRrect.size )
    image.drawInRect( CGRectMake(1,1,image.size.width-2,image.size.height-2) )
    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image

  end

  def self.from_color(color)
    rect = CGRectMake(0, 0, 1, 1)
    # Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    color.setFill
    UIRectFill(rect)   # Fill it with your color
    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
  end

  def self.from_sym(sym)
    if sym.is_a?(Symbol)
      UIImage.imageNamed(AppDelegate::IMAGES[sym])
    else
      UIImage.imageNamed(sym)
    end
  end

  def croppedToSize(targetSize)
    sourceImage = self
    return nil if sourceImage.nil?

    imageSize = sourceImage.size
    width = imageSize.width
    height = imageSize.height
    targetWidth = targetSize.width
    targetHeight = targetSize.height
    scaleFactor = 0.0
    scaledWidth = targetWidth
    scaledHeight = targetHeight
    thumbnailPoint = CGPointMake(0.0, 0.0)

    if CGSizeEqualToSize(imageSize, targetSize) == false
      widthFactor = targetWidth / width
      heightFactor = targetHeight / height

      scaleFactor = widthFactor > heightFactor ? widthFactor : heightFactor
      scaledWidth = width * scaleFactor
      scaledHeight = height * scaleFactor

      if widthFactor > heightFactor
        thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
      elsif widthFactor < heightFactor
        thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
      end
    end

    # now size image

    UIGraphicsBeginImageContext(targetSize)
    thumbnailRect = CGRectZero
    thumbnailRect.origin = thumbnailPoint
    thumbnailRect.size.width = scaledWidth
    thumbnailRect.size.height = scaledHeight
    sourceImage.drawInRect(thumbnailRect)
    newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage

  end

  def stretchedToSize(targetSize)
    UIGraphicsBeginImageContext(targetSize)
    self.drawInRect(CGRectMake(0, 0, targetSize.width, targetSize.height))
    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image
  end

  def qw_crop(size)
    self.cropToSize(size, usingMode: NYXCropModeCenter)
  end

end
