# encoding: utf-8
require 'network_manager/modem'

class NetworkManager
  attr_reader :service, :bus_path, :mm_object

  def initialize(opts = {})
    set_options opts
    @bus        = DBus::SystemBus.instance
    @mm_service = @bus[@service]
    @mm_object  = @mm_service.object(@bus_path)
    @mm_object.introspect
  end

  # Discover all enabled devices
  def devices(opts = {})
    @devices = []
    @mm_object.introspect
    NetworkManager::Modem.fetch(@mm_object.EnumerateDevices())
  end

  class << self

  end

  protected

  def set_options(opts = {})
    @service    ||= 'org.freedesktop.ModemManager'
    @bus_path   ||= '/org/freedesktop/ModemManager'

    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

end
