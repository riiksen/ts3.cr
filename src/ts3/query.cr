require "enums/*"

module Ts3
  class Query
    private runtime = {
      socket: "",
      selected: false,
      host: "",
      queryport: 10011,
      timeout: 2,
      debug: [] of String,
      fileSocket: "",
      bot_clid: "",
      bot_name: ""
    }

    HOST_MESSAGE_MODE_NONE = 0
    HOST_MESSAGE_MODE_LOG = 1
    HOST_MESSAGE_MODE_MODAL = 2
    HOST_MESSAGE_MODE_MODALQUIT = 3
  
    HOST_BANNER_MODE_NOADJUST = 0
    HOST_BANNER_MODE_IGNOREASPECT = 1
    HOST_BANNER_MODE_KEEPASPECT = 2
  
    CODEC_SPEEX_NARROWBAND = 0
    CODEC_SPEEX_WIDEBAND = 1
    CODEC_SPEEX_ULTRAWIDEBAND = 2
    CODEC_CELT_MONO = 3
    CODEC_OPUS_VOICE = 4
    CODEC_OPUS_MUSIC = 5
  
    CODEC_CRYPT_INDIVIDUAL = 0
    CODEC_CRYPT_DISABLED = 1
    CODEC_CRYPT_ENABLED = 2
  
    TEXT_MESSAGE_TARGET_CLIENT = 1
    TEXT_MESSAGE_TARGET_CHANNEL = 2
    TEXT_MESSAGE_TARGET_SERVER = 3
  
    LOG_LEVEL_ERROR = 1
    LOG_LEVEL_WARNING = 2
    LOG_LEVEL_DEBUG = 3
    LOG_LEVEL_INFO = 4
  
    REASON_KICK_CHANNEL = 4
    REASON_KICK_SERVER = 5

    PERM_GROUP_DB_TYPE_TEMPLATE = 0
    PERM_GROUP_DB_TYPE_REGULAR = 1
    PERM_GROUP_DB_TYPE_QUERY = 2

    PERM_GROUP_TYPE_SERVER_GROUP = 0
    PERM_GROUP_TYPE_GLOBAL_CLIENT = 1
    PERM_GROUP_TYPE_CHANNEL = 2
    PERM_GROUP_TYPE_CHANNEL_GROUP = 3
    PERM_GROUP_TYPE_CHANNEL_CLIENT = 4

    TOKEN_SERVER_GROUP = 0
    TOKEN_CHANNEL_GROUP = 1

    def initialize(host : String, queryport : Int32, timeout : Int32 = 2)
      if queryport >= 1 && queryport <= 65536
        if timeout >= 1
          self.runtime[:host] = host
          self.runtime[:queryport] = queryport
          self.runtime[:timeout] = timeout
        else
          self.addDebugLog("invalid timeout value")
        end
      else
        self.addDebugLog("invalid queryport")
      end
    end

    def finalize
      self.quit()
    end

    def ban_add_by_ip(ip : String, time : Int32 = 0, banreason : String = nil)
      return self.check_selected() if !self.runtime[:selected]

      if !banreason
        msg = " banreason=#{self.escapeText(banreason)}"
      else
        msg = nil
      end

      return self.get_data("array", "banadd ip=#{ip} time=#{time}#{msg}")
    end

    def ban_add_by_uid(uid : String, time : Int32 = 0, banreason : String = nil)
      return self.check_selected() if !self.runtime[:selected]

      if !banreason
        msg = " banreason=#{self.escapeText(banreason)}"
      else
        msg = nil
      end

      return self.get_data("array", "banadd uid=#{uid} time=#{time}#{msg}")
    end

    def ban_add_by_name(name : String, time : Int32 = 0, banreason : String = nil)
      return self.check_selected() if !self.runtime[:selected]

      if !banreason
        msg = " banreason=#{self.escapeText(banreason)}"
      else
        msg = nil
      end

      return self.get_data("array", "banadd name=#{name} time=#{time}#{msg}")
    end

    def ban_client(clid : Int32, time : Int32 = 0, banreason : String = nil)
      return self.check_selected() if !self.runtime[:selected]

      if !banreason
        msg = " banreason=#{self.escapeText(banreason)}"
      else
        msg = nil
      end

      result = self.get_data("plain", "banclient clid=#{clid} time=#{time}#{msg}")

      if result[:success]
        return self.generate_output(true, result[:errors], self.split_ban_ids(result[:data]))
      else
        return self.generate_output(false, result[:errors], false)
      end
    end

    def ban_delete(banid : Int32) : Bool
      return self.check_selected() if !self.runtime[:selected]

      return self.get_data("boolean", "bandel banid=#{banid}")
    end

    def ban_delete_all : Bool
      return self.check_selected() if !self.runtime[:selected]

      return self.get_data("boolean", "bandelall")
    end

    def ban_list
      return self.check_selected() if !self.runtime[:selected]

      return self.get_data("multi", "banlist")
    end

    def binding_list(subsystem : Int32 = 0) # TODO:

      return self.get_data("multi", "bindinglist")
    end

    def channel_add_perm(cid : Int32, permissions) : Bool
      
    end

    def channel_client_add_perm(cid : Int32, cldbid : Int32, permissions) : Bool
      
    end

    def channel_client_del_perm(cid : Int32, cldbid : Int32, permissions) : Bool

    end

    def channel_client_perm_list(cid : Int32, cldbid : Int32, permsid : Bool = false) : Bool
      return self.check_selected() if !self.runtime[:selected]

      return self.get_data("multi", "channelclientpermlist cid=#{cid} cldbid=#{cldbid}#{permsid ? "-permsid" : ""}") #TODO: Check if this ternary if works
    end

    def channel_create(data)
      return self.check_selected() if !self.runtime[:selected]

      properties_string = ""
      data.each do |key, value|
        properties_string += " #{key.downcase}=#{self.escape_text(value)}"
      end
      return self.get_data("array", "channelcreate #{properties_string}")
    end

    def channel_delete(cid : Int32, force : Int32 = 1) : Bool
      return self.check_selected() if !self.runtime[:selected]
      return self.get_data("boolean", "channeldelete cid=#{cid} force=#{force}")
    end

    def channel_del_perm(cid : Int32, permissions) : Bool # TODO:
      return self.check_selected() if !self.runtime[:selected]
    end

    def channel_edit(cid : Int32, data) : Bool
      return self.check_selected() if !self.runtime[:selected]

      settings_string = ""
      data.each do |key, value|
        settings_string += " #{key.downcase}=#{self.escape_text(value)}"
      end
      return self.get_data("boolean", "channeledit cid=#{cid}#{settings_string}")
    end

    def channel_find(pattern : String)
      return self.check_selected() if !self.runtime[:selected]
      return self.get_data("multi", "channelfind pattern=#{self.escape_text(pattern)}")
    end

    def channel_get_icon_by_channel_id(channelid : String)
      return self.check_selected() if !self.runtime[:selected]

      if channelid.empty?
        return self.generate_output(false, ) # TODO:
      end

      channel = self.channel_info(channelid)

      if !channel[:success]
        return self.generate_output(false, channel[:error], false)
      end

      return self.get_icon_by_id(channel[:data][:channel_icon_id])
    end

    def channel_group_add(name : Int32, type : Int32 = 1) : Bool
      return self.check_selected() if !self.runtime[:selected]
      return self.get_data("array", "channelgroupadd name=#{self.escape_text(name)} type=#{type}")
    end

    def channel_group_add_client(cgid : Int32, cid : Int32, cldbid : Int32) : Bool
      return self.set_client_channel_group(cgid, cid, cldbid)
    end

    private is_connected : Bool
      return !self.runtime[:socket]
    end

    private def generate_output(success : Bool, errors, data)
      return {
        success: success,
        errors: errors,
        data: data
      }
    end

    private def un_escape_text(text : String) : String #TODO: 
      
    end

    private def escape_text(text : String) : String # TODO:
      
    end

    private def split_ban_ids(text : String) : String # TODO:
      
    end

    def get_query_clid : Int32
      return self.runtime[:bot_clid]
    end

    private def execute_command(command : String, tracert : Nil) # TODO:
      
    end

    def read_chat_message(type : String = "textchannel", keepalive : Bool = false, cid : Int32 = -1) # TODO:
      
    end

    def server_notify_unregister # TODO: 
      self.execute_command("servernotifyunregister", nil)
    end

    private def get_data(mode : String, command : String) # TODO:
      valid_modes = ["boolean", "array", "multi", "plain"]

      if valid_modes.includes?(mode)
        self.add_debug_log("#{mode} is an invalid mode")
        return self.generate_output(false, )
      end
    end

    def get_debug_log
      return self.runtime[:debug]
    end

    private def add_debug_log(text : String) # TODO:
      self.runtime[:debug]
    end
  end
end
