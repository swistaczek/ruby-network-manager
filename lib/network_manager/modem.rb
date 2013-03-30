# encoding: utf-8
class NetworkManager
  class Modem
    attr_reader :bus_path, :service

    def initialize(opts = {})
      opts.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end

      # Set DBUS proxy
      @proxy = @service.object(@bus_path)
      @proxy.introspect

      @properties = @proxy.dup
      @properties.default_iface = NetworkManager::DBUS_PROPERTIES
      @properties.introspect

      @s_modem = @proxy[NetworkManager::MM_DBUS_INTERFACE_MODEM_SIMPLE]
      @modem   = @proxy[NetworkManager::MM_DBUS_INTERFACE_MODEM]
      @network = @proxy[NetworkManager::MM_DBUS_INTERFACE_MODEM_GSM_NETWORK]
      @ussd    = @proxy[NetworkManager::MM_DBUS_INTERFACE_MODEM_GSM_USSD]

      @device_info = @properties.GetInfo[0] rescue nil
    end

    def enabled?
      begin
        status
        return true
      rescue => e
        return !e.message.include?('device is not enabled')
      end
      nil
    end

    def enable!
      @modem.Enable(true) == [] if disabled?
    end

    def disabled?
      !enabled?
    end

    def disable!
      @modem.Enable(false) == [] if enabled?
    end

    def model
      @device_info[1] rescue nil
    end

    def status
      @s_modem.GetStatus[0]
    end

    def operator_code
      status["operator_code"] rescue nil
    end

    def vendor
      @device_info[0] rescue nil
    end

    def version
      @device_info[2] rescue nil
    end

    def signal
      @properties.GetSignalQuality[0] rescue 0
    end

    def imei
      @properties.GetImei[0] rescue nil
    end

    def imsi
      @properties.GetImsi[0] rescue nil
    end

    def scan
      @network.Scan[0] rescue nil
    end

    def send_ussd(message)
      @ussd.Cancel
      @ussd.Initiate(message)
    end

    def inspect
      "#<NetworkManager::Modem##{object_id} IMEI: #{imei} Device: #{vendor} #{model} #{version} >"
    end

    class << self
      def fetch(paths_array, opts = {})
        devices = []
        paths_array.compact.reject {|x| x && x.size <= 0 }.each do |path|
          devices << self.new(opts.merge({bus_path: path}))
        end
        devices
      end
    end
  end
end