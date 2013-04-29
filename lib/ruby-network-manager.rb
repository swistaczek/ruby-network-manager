# encoding: utf-8
require 'dbus'
require 'network_manager/modem'

class NetworkManager
  attr_reader :modem_service, :modem_bus_path

  MODEM_MANAGER_BUS_PATH              = '/org/freedesktop/ModemManager'
  DBUS_PROPERTIES                     = 'freedesktop.DBus.Properties'
  MM_DBUS_SERVICE                     = 'org.freedesktop.ModemManager'
  MM_DBUS_INTERFACE_MODEM             = 'org.freedesktop.ModemManager.Modem'
  MM_DBUS_INTERFACE_MODEM_CDMA        = 'org.freedesktop.ModemManager.Modem.Cdma'
  MM_DBUS_INTERFACE_MODEM_GSM_CARD    = 'org.freedesktop.ModemManager.Modem.Gsm.Card'
  MM_DBUS_INTERFACE_MODEM_GSM_NETWORK = 'org.freedesktop.ModemManager.Modem.Gsm.Network'
  MM_DBUS_INTERFACE_MODEM_SIMPLE      = 'org.freedesktop.ModemManager.Modem.Simple'
  MM_DBUS_INTERFACE_MODEM_GSM_USSD    = 'org.freedesktop.ModemManager.Modem.Gsm.Ussd'

  def initialize(opts = {})
    set_options opts
    @bus        = DBus::SystemBus.instance
  end

  # Discover all enabled devices
  def modems(opts = {})
    @mm_service ||= @bus[@modem_service]
    @mm_object  ||= @mm_service.object(@modem_bus_path)
    @mm_object.introspect

    NetworkManager::Modem.fetch(@mm_object.EnumerateDevices()[0], service: @mm_service)
  end

  # def on_device_add(&block)
  #   @bus        = DBus::SystemBus.instance
  #   @mm_service = @bus.service('org.freedesktop.ModemManager')
  #   @mm_object  = @mm_service.object('/org/freedesktop/ModemManager')
  #   @mm_object.introspect

  #   @properties = @mm_object.dup
  #   @properties.default_iface = DBUS_PROPERTIES
  #   @properties.introspect

  #   @properties.on_signal('DeviceAdded') {|x| puts x}
  # end

  protected

  def set_options(opts = {})
    @modem_service  ||= MM_DBUS_SERVICE
    @modem_bus_path ||= MODEM_MANAGER_BUS_PATH

    opts.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

end
