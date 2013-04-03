class IncomingRequest
  def initialize(rack_request)
    @rack_request = rack_request
  end
  
  def has_query_string?
    !@rack_request.GET.empty?
  end
  
  def query_string_matches?(query_params)
    query_params.keys.all? do |param_name|
      @rack_request.GET.has_key?(param_name.to_s)
    end
  end
end
