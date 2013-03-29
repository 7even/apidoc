module BodyProcessor
  class << self
    def process_for_rendering(body)
      object = Oj.load(body)
      json = JSON.pretty_generate(object)
      json.gsub(/\"#\{([A-Za-z0-9_]+)\}\"/, '\1')
    end
  end
end
