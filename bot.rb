require 'byebug'
require 'discordrb'
require 'net/http'
require 'redis'
require 'uri'

def redis
  @redis ||= redis = Redis.new(url: ENV['RADIS_URL'])
end

bot = Discordrb::Bot.new(
  token: ENV['TOKEN'],
  intents: [Discordrb::INTENTS[:server_messages]]
)
bot.message(from: 'Raider.IO') do |event|
  next unless (embed = event.message.embeds[0])
  next unless embed.description =~ /[а-яА-Я]/

  thread = event.channel.start_thread("#{Time.now}", 1440, message: event.message)
  names = names(embed.description, 'Tauren Milfs')
  thread.send_message("<@&#{event.server.roles.find { _1.name == 'Officer' }.id}> Imposter detected. #{names.join(', ')}")
end

def names(description, guild_pattern)
  regex = %r{https://raider.io/characters/eu/(?<realm>.+)/(?<name>.+)\?}
  players = description.scan(regex)
  parser = URI::Parser.new
  names = players.select do |realm, name|
    uri = URI.parse("https://raider.io/api/v1/characters/profile?region=eu&realm=#{realm}&name=#{parser.escape(name)}&fields=guild")
    response = Net::HTTP.get_response(uri)
    guild = JSON.parse(response.body).dig('guild', 'name')
    guild_pattern === guild
  rescue Exception => e
    Discordrb::LOGGER.error(e.message)
    false
  end.map(&:last)
  names
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
