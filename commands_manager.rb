class CommandsManager
  def self.register(bot)
    bot.register_application_command(:setup, 'Setup bot') do |cmd|
      cmd.string('guild_name', 'Guild Name')
      cmd.string('officer_role_id', 'Officer Role ID')
    end

    bot.application_command(:setup) do |event|
      server = Server.new(event.server)
      server.setup(event.options)
      event.respond(content: "Guild Name: #{server.guild_name}\nOfficer Role ID: #{server.officer_role_id}", ephemeral: true)
    end

    bot.register_application_command(:info, 'Show setup details', server_id: '697004853494546473') do |cmd|
    end

    bot.application_command(:info) do |event|
      server = Server.new(event.server)
      event.respond(content: "Guild Name: #{server.guild_name}\nOfficer Role ID: #{server.officer_role_id}", ephemeral: true)
    end

    bot.register_application_command(:'add-guild-to-whitelist', 'Whitelist a guild') do |cmd|
      cmd.string('guild', 'Guild name')
    end

    bot.application_command(:'add-guild-to-whitelist') do |event|
      server = Server.new(event.server)
      guilds = server.whitelist_guild(event.options['guild'])
      event.respond(content: guilds.join(', '), ephemeral: true)
    end

    bot.register_application_command(:'remove-guild-from-whitelist', 'Remove guild from a whitelist') do |cmd|
      cmd.string('guild', 'Guild name')
    end

    bot.application_command(:'remove-guild-from-whitelist') do |event|
      server = Server.new(event.server)
      guilds = server.remove_guild_from_whitelist(event.options['guild'])
      event.respond(content: guilds.join(', '), ephemeral: true)
    end
  end
end
