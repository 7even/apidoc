module ConsoleHelpers
  # a helper for prettyprinting mongoid objects
  def jp(object)
    Oj.load(object.to_json)
  end
end
