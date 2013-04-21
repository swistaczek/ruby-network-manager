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
      @properties['org.freedesktop.ModemManager.Modem']['Enabled']
    end
    alias :enabled? :status

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
      rsp = case ussd_state
      when 'idle'
        @ussd.Initiate(message)
      when 'active'
        @ussd.Cancel rescue nil
        @ussd.Initiate(message)
      when 'user-response'
        @ussd.Respond(message)
      end

      # @ussd.Cancel rescue nil
      rsp[0] if rsp.is_a?(Array)
    end

    def device
      {
        model: model,
        port: @properties[MM_DBUS_INTERFACE_MODEM]['Device'],
        unlock_required: @properties[MM_DBUS_INTERFACE_MODEM]['UnlockRequired'],
        master_device: @properties[MM_DBUS_INTERFACE_MODEM]['MasterDevice'],
        dbus_path: @bus_path
      }
    end

    def ussd_state
      @properties['org.freedesktop.ModemManager.Modem.Gsm.Ussd']['State']
    end

    def inspect
      if enabled?
        "#<NetworkManager::Modem##{object_id} IMEI: #{imei} Device: #{vendor} #{model} #{version} USSD_STATE: #{ussd_state}>"
      else
        "#<NetworkManager::Modem##{object_id} DISABLED Device: #{vendor} #{model} #{version}"
      end
    end

    def to_h
      {
        imei: imei,
        imsi: imsi,
        signal: signal,
        operator_code: operator_code, 
        device: device,
        status: (enabled? ? :enabled : :disabled )
      }
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