# encoding: utf-8
require 'dbus'
require 'network_manager/modem'

class NetworkManager
  attr_reader :modem_service, :modem_bus_path

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

  class << self

  end

  protected

  def set_options(opts = {})
    @modem_service  ||= MM_DBUS_SERVICE || 'org.freedesktop.ModemManager'
    @modem_bus_path ||= '/org/freedesktop/ModemManager'

    opts.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

end
