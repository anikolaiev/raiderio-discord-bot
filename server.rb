require './db'

class Server
  attr_reader :server

  def initialize(server)
    @server = server
  end

  def setup(opts)
    DB.set("settings:#{server.id}:guild_name", opts['guild_name']) if opts['guild_name']
    DB.set("settings:#{server.id}:officer_role_id", opts['officer_role_id']) if opts['officer_role_id']
  end

  def info
    { guild: DB.get("settings:#{server.id}:guild"), officer_role_id: DB.get("settings:#{server.id}:officer_role_id") }
  end

  def whitelisted_guilds
    JSON.parse(DB.get("settings:#{server.id}:whitelisted_guilds") || '[]')
  end

  def whitelist_guild(guild_name)
    guilds = whitelisted_guilds
    guilds.push(guild_name).uniq!
    DB.set("settings:#{server.id}:whitelisted_guilds", guilds)
    guilds
  end

  def remove_guild_from_whitelist(guild_name)
    guilds = whitelisted_guilds
    guilds.delete(guild_name)
    DB.set("settings:#{server.id}:whitelisted_guilds", guilds)
    guilds
  end

  def whitelisted_players
    JSON.parse(DB.get("settings:#{server.id}:whitelisted_players") || '[]')
  end

  def add_strike(player)
    strikes = DB.get("player:#{server.id}:#{player}").to_i + 1
    DB.set("player:#{server.id}:#{player}", strikes)
    strikes
  end

  def officer_role_id
    DB.get("settings:#{server.id}:officer_role_id")
  end

  def guild_name
    DB.get("settings:#{server.id}:guild_name")
  end
end
