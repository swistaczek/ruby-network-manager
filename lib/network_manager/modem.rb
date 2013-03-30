# encoding: utf-8
class NetworkManager::Modem
  attr_reader :bus_path

  def initialize(opts)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  class << self
    def fetch(paths_array)
      devices = []
      paths_array.each do |path|
        devices << self.new(bus_path: path) unless path.nil?
      end
      devices
    end
  end

end