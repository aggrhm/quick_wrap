class UIButton

  def qw_title(title, state=UIControlStateNormal)
    self.setTitle(title, forState: state)
  end

  def qw_image(img, state=UIControlStateNormal)
    img = UIImage.from_sym(img) unless img.is_a?(UIImage)
    self.setImage(img, forState: state)
  end

  def qw_action(&block)
    self.when(UIControlEventTouchUpInside, &block)
  end

end
