module BodyProcessor
  class << self
    def process_for_rendering(body)
      json = JSON.pretty_generate(body)
      json.gsub(/\"#\{([A-Za-z0-9_]+)\}\"/, '\1')
    end
  end
end
