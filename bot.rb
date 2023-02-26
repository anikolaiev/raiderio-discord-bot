require 'byebug'
require 'discordrb'
require 'net/http'
require 'redis'
require 'uri'

def redis
  @redis ||= Redis.new(url: ENV['REDIS_URL'])
end

bot = Discordrb::Bot.new(
  token: ENV['TOKEN'],
  intents: [Discordrb::INTENTS[:server_messages], Discordrb::INTENTS[:server_members]]
)
bot.message(from: 'Raider.IO') do |event|
  next unless (embed = event.message.embeds[0])
  next unless embed.description =~ /[а-яА-Я]/

  thread = event.channel.start_thread("#{Time.now}", 1440, message: event.message)
  names = names(embed.description, 'Tauren Milfs')
  whitelist = redis.get('settings:whitelist') || []
  next if names.all? { |name| whitelist.include?(name) }

  strikes = names.map do |name|
    count = redis.get("player:#{name}").to_i + 1
    redis.set("player:#{name}", count)
    count
  end
  imposters = names.zip(strikes).map do |name, count|
    "#{name} (#{count} #{count > 1 ? 'strikes' : 'strike'})"
  end
  thread.send_message("<@&#{officer_role_id(event)}> Imposter detected. #{imposters.join(', ')}")
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

def officer_role_id(event)
  event.server.roles.find { _1.name == 'Officer' }.id
end


bot.message(from: 'Andrii', with_text: 'Ping!') do |event|
  event.respond 'Pong!'
end

bot.message(from: 'Andrii', start_with: 'eval: ') do |event|
  command = event.message.content.split('eval: ').last
  event.respond eval(command) || 'no value'
end

bot.run

__END__
# my_server_id = '656930170393067531'
# tm_server_id = '697004853494546473'
# response = Discordrb::API::Server.channels(bot.token, tm_server_id)
# message = JSON.parse(response.body).map{ Discordrb::Channel.new(_1, bot) }.find{ _1.name == 'raider-io' }.history(1).first
# embed = message.embeds[0]
# embed.description =~ /[а-яА-Я]/
