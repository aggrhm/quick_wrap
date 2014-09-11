class UIViewController

  def weak_ref
    WeakRef.new(self)
  end

end
