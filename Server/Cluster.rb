module VMS
  class Cluster
    attr_reader :id
    attr_reader :players

    def initialize(id=-1, server=nil)
      @id = id
      @players = {}
      @server = server
    end

    def add_player(player)
      @players[player.id] = player
    end

    def remove_player(player)
      @players.delete(player.id)

      # Let all players know that the player has disconnected
      @players.each_value do |p|
        @server.send([:disconnect_player, player.id], p.address, p.port)
      end

      # If the cluster is empty, remove it
      if @players.length == 0
        @server.remove_cluster(@id)
      end
    end

    def player_count
      return @players.length
    end

    def has_player(address, port)
      @players.each_value do |player|
        if player.address == address && player.port == port
          return true
        end
      end
      return false
    end

    def update_players
      # Remove players that have not sent a heartbeat in a while
      @players.each_value do |player|
        if Time.now - player.heartbeat > Config.heartbeat_timeout
          @server.log("Player #{player.name} (#{player.id}) timed out.")
          remove_player(player)
        end
      end
      # Send player data to all players
      data = []
      @players.each_value do |player|
        data.push(player.to_hash)
      end
      @players.each_value do |player|
        @server.send(data, player.address, player.port)
      end
    end
  end
end