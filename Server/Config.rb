module VMS
  class Config
    CONFIG_PATH = "./config.ini"

    def self.host
      get_line("host").chomp
    end

    def self.port
      get_line("port").chomp.to_i
    end

    def self.max_players
      get_line("max_players").chomp.to_i
    end

    def self.log
      get_line("log").chomp == "true"
    end

    def self.heartbeat_timeout
      get_line("heartbeat_timeout").chomp.to_i
    end

    def self.use_tcp
      get_line("use_tcp").chomp == "true"
    end

    def self.get_line(line)
      File.open(CONFIG_PATH, "r") do |file|
        file.each_line do |l|
          if l.split(" = ")[0] == line
            return l.split(" = ")[1]
          end
        end
      end
    end
  end
end