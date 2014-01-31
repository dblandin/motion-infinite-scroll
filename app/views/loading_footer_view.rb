class LoadingFooterView < UIView
  def initWithFrame(frame)
    super.tap do |view|
      view.setup_constraints

      view.hidden = true
    end
  end

  def setup_constraints
    Motion::Layout.new do |layout|
      layout.view       self
      layout.subviews   'label' => label
      layout.horizontal '|[label]|'
      layout.vertical   '|[label]|'
    end
  end

  def begin_loading
    self.hidden = false

    label.text = 'Loading...'
  end

  def stop_loading
    self.hidden = true
  end

  def end_loading
    self.hidden = false

    label.text = 'No more items!'
  end

  def label
    @label ||= UILabel.alloc.init.tap do |label|
      label.adjustsFontSizeToFitWidth = true
      label.backgroundColor           = UIColor.whiteColor
      label.font                      = UIFont.fontWithName('HelveticaNeue-Light', size: 18.0)
      label.textAlignment             = NSTextAlignmentCenter
      label.textColor                 = UIColor.darkGrayColor
    end
  end
end

