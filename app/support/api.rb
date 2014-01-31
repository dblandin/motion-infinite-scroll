class API
  API_KEY = '89cf0cb3905f5bd901be336c0da6233b'

  def self.shared
    @shared ||= new
  end

  def get(path, params = {}, &block)
    params = params.merge(key: API_KEY)

    manager.GET(
      path,
      parameters: params,
      success: success_callback(block).weak!,
      failure: failure_callback(block).weak!)
  end

  def success_callback(block)
    -> (operation, response) do
      block.call(true, operation, response)
    end
  end

  def failure_callback(block)
    -> (operation, error) do
      block.call(false, operation, error)
    end
  end

  def base_url
    NSURL.URLWithString('http://api.brewerydb.com/v2/')
  end

  def manager
    @manager ||= AFHTTPRequestOperationManager.alloc.initWithBaseURL(base_url).tap do |manager|
      manager.responseSerializer = AFJSONResponseSerializer.serializer
      manager.requestSerializer  = AFHTTPRequestSerializer.serializer
    end
  end
end
