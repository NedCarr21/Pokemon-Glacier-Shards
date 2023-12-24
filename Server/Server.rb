module VMS
  require 'socket'
  require_relative 'Config'
  require_relative 'Cluster'
  require_relative 'Player'

  class Server
    attr_reader :socket
    attr_accessor :clusters

    def initialize
      if Config.use_tcp
        @socket = TCPServer.new(Config.host, Config.port)
      else
        @socket = UDPSocket.new
        @socket.bind(Config.host, Config.port)
      end
      @clients = {}
      @clusters = {}
      begin
        run
      rescue Interrupt
        log("Server has been stopped by the user.")
      rescue => e
        log("Server stopped with error: #{e}", true)
      end
    end

    def run
      log("Server started on #{Config.host}:#{Config.port}.")
      loop do
        # Update clusters
        @clusters.each_value do |cluster|
          cluster.update_players
        end
        begin
          # Receive data from clients
          if Config.use_tcp
            @clients.each_value do |client|
              data = client.recv_nonblock(65536, exception: false)
              next if data == :wait_readable || data == :wait_writable || data.nil?
              data = Marshal.load(data)
              # Handle data
              case data[0]
              when "connect"
                connect(client.addr[3], client.addr[1], data[1])
              when "disconnect"
                disconnect(client.addr[3], client.addr[1], data[1])
              when "update"
                update(client.addr[3], client.addr[1], data[1])
              end
            end
            # Accept new clients
            client = @socket.accept_nonblock(exception: false)
            next if client == :wait_readable || client == :wait_writable || client.nil?
            @clients[client.addr] = client
          else
            data, address, port = @socket.recvfrom_nonblock(65536, exception: false)
            next if data == :wait_readable || data == :wait_writable || data.nil? || address.nil?
            port = address[1]
            address = address[3]
            data = Marshal.load(data)        
            # Handle data
            case data[0]
            when "connect"
              connect(address, port, data[1])
            when "disconnect"
              disconnect(address, port, data[1])
            when "update"
              update(address, port, data[1])
            end
          end
        rescue
        end
      end
    end

    def connect(address, port, data)
      if cluster_exists(data[:cluster_id])
        if @clusters[data[:cluster_id]].player_count < Config.max_players
          @clusters[data[:cluster_id]].add_player(Player.new(data[:id], address, port))
          update(address, port, data)
          log("#{get_player_name(data)} connected to cluster #{data[:cluster_id]}.")
        else
          log("#{get_player_name(data)} tried to connect to cluster #{data[:cluster_id]}, but it was full.")
          send(:disconnect_full, address, port)
        end
      else
        @clusters[data[:cluster_id]] = Cluster.new(data[:cluster_id] || @clusters.length, self)
        @clusters[data[:cluster_id]].add_player(Player.new(data[:id], address, port))
        update(address, port, data)
        log("#{get_player_name(data)} connected to newly created cluster #{data[:cluster_id]}.")
      end
    end

    def disconnect(address, port, data)
      if cluster_exists(data[:cluster_id])
        if @clusters[data[:cluster_id]].has_player(address, port)
          @clusters[data[:cluster_id]].remove_player(data[:id])
          log("#{get_player_name(data)} disconnected from cluster #{data[:cluster_id]}.")
        else
          log("#{get_player_name(data)} tried to disconnect from cluster #{data[:cluster_id]}, but they weren't connected.")
        end
      else
        log("#{get_player_name(data)} tried to disconnect from cluster #{data[:cluster_id]}, but it didn't exist.")
      end
      send(:disconnect, address, port)
    end

    def update(address, port, data)
      if cluster_exists(data[:cluster_id])
        if @clusters[data[:cluster_id]].has_player(address, port)
          @clusters[data[:cluster_id]].players[data[:id]].update(data)
        else
          log("#{get_player_name(data)} tried to update cluster #{data[:cluster_id]}, but they weren't connected.", true)
          connect(address, port, data)
        end
      else
        log("#{get_player_name(data)} tried to update cluster #{data[:cluster_id]}, but it didn't exist.")
        connect(address, port, data)
      end
    end

    def send(data, address, port)
      if Config.use_tcp
        @clients.each_value do |client|
          begin
            client.send(Marshal.dump(data), 0)
          rescue
            log("Client #{client.addr} disconnected.")
            @clients.delete(client.addr)
          end
        end
      else
        @socket.send(Marshal.dump(data), 0, address, port)
      end
    end

    def log(message="", warning=false)
      puts "[#{Time.now.strftime("%H:%M:%S")}] #{warning ? "WARNING: " : ""}#{message}" if Config.log
    end

    def get_player_name(data)
      return "Player #{data[:name]} (#{data[:id]})"
    end

    def cluster_exists(id)
      @clusters.each_value do |cluster|
        if cluster.id == id
          return true
        end
      end
      return false
    end

    def remove_cluster(id)
      @clusters.delete(id)
    end
  end

  Server.new
end