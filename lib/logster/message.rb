module Logster
  class Message
    LOGSTER_ENV = "_logster_env".freeze
    ALLOWED_ENV = %w{
      HTTP_HOST
      REQUEST_URI
      REQUEST_METHOD
      HTTP_USER_AGENT
    }

    attr_accessor :timestamp, :severity, :progname, :message, :key, :backtrace, :env

    def initialize(severity, progname, message, timestamp = nil, key = nil)
      @timestamp = timestamp || get_timestamp
      @severity = severity
      @progname = progname
      @message = message
      @key = key || SecureRandom.hex
      @backtrace = nil
    end

    def to_h
      {
        message: @message,
        progname: @progname,
        severity: @severity,
        timestamp: @timestamp,
        key: @key,
        backtrace: @backtrace,
        env: @env
      }
    end

    def to_json(opts=nil)
      JSON.fast_generate(to_h,opts)
    end

    def self.from_json(json)
      parsed = ::JSON.parse(json)
      msg = new( parsed["severity"],
            parsed["progname"],
            parsed["message"],
            parsed["timestamp"],
            parsed["key"] )
      msg.backtrace = parsed["backtrace"]
      msg.env = parsed["env"]
      msg
    end

    def populate_from_env(env)
      @env = Message.populate_from_env(env)
    end


    def self.populate_from_env(env)
      env[LOGSTER_ENV] ||= begin
          scrubbed = {}
          ALLOWED_ENV.map{ |k|
           scrubbed[k] = env[k] if env[k]
          }
          scrubbed
      end
    end

    protected

    def get_timestamp
      (Time.new.to_f * 1000).to_i
    end
  end
end
