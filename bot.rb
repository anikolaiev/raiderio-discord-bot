require 'byebug'
require 'discordrb'
require './commands_manager'
require './helper'
require './server'

bot = Discordrb::Bot.new(
  token: ENV['TOKEN'],
  intents: [Discordrb::INTENTS[:server_messages], Discordrb::INTENTS[:server_members]]
)
CommandsManager.register(bot)

bot.message(from: 'Raider.IO') do |event|
  server = Server.new(event.server)
  next unless (embed = event.message.embeds[0])
  next unless Helper.russian_in_group?(server, embed.description)

  suspects = Helper.suspects(embed.description, server.guid_name)
  whitelist = server.whitelisted_players
  next if suspects.any? && suspects.all? { |name| whitelist.include?(name) }

  thread = event.channel.start_thread(Time.now.to_s, 1440, message: event.message)
  strikes = suspects.map { |name| server.add_strike(name) }
  suspects = suspects.zip(strikes).map do |name, count|
    "#{name} (#{count} #{count > 1 ? 'strikes' : 'strike'})"
  end
  thread.send_message("<@&#{server.officer_role_id}> Imposter detected. #{suspects.join(', ')}")
end

bot.message(from: 'Andrii', with_text: 'Ping!') do |event|
  event.respond 'Pong!'
end

bot.run

__END__
# my_server_id = '656930170393067531'
# tm_server_id = '697004853494546473'
# response = Discordrb::API::Server.channels(bot.token, tm_server_id)
# message = JSON.parse(response.body).map{ Discordrb::Channel.new(_1, bot) }.find{ _1.name == 'raider-io' }.history(1).first
# embed = message.embeds[0]
# embed.description =~ /[а-яА-Я]/
