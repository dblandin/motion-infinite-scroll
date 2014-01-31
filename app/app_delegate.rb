class AppDelegate
  attr_reader :window

  def application(application, didFinishLaunchingWithOptions: launch_options)
    initialize_main_controller

    true
  end

  def initialize_main_controller
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    window.setRootViewController(build_root_controller)
    window.makeKeyAndVisible
  end

  def build_root_controller
    controller = StylesController.alloc.init

    UINavigationController.alloc.initWithRootViewController(controller)
  end
end
