require 'uri'
require 'discordrb'
require 'net/http'

module Helper
  extend self

  PLAYER_REGEX = %r{https://raider.io/characters/eu/(?<realm>.+)/(?<name>.+)\?}
  CYRILLIC_REGEX = /[а-яА-Я]/

  def embed_hash(embed)
    return {} unless embed

    {
      color: embed.color,
      description: embed.description,
      title: embed.title,
      footer: {
        icon_url: embed.footer&.icon_url,
        proxy_icon_url: embed.footer&.proxy_icon_url,
        text: embed.footer&.text
      }.compact,
      image: {
        height: embed.image&.height,
        proxy_url: embed.image&.proxy_url,
        url: embed.image&.url,
        width: embed.image&.width
      }.compact
    }.compact
  end

  def guild_name(realm, player_name)
    parser = URI::Parser.new
    uri = URI.parse("https://raider.io/api/v1/characters/profile?region=eu&realm=#{realm}&name=#{parser.escape(player_name)}&fields=guild")
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body).dig('guild', 'name')
  end

  def russian_in_group?(server, description)
    return unless description =~ CYRILLIC_REGEX

    guilds = server.whitelisted_guilds
    names_and_realms(description).any? do |realm, player_name|
      player_name =~ CYRILLIC_REGEX && !guilds.include?(guild_name(realm, player_name))
    rescue Exception => e
      Discordrb::LOGGER.error(e.message)
      false
    end
  end

  def names_and_realms(description)
    description.scan(PLAYER_REGEX)
  end

  def suspects(description, guild)
    names_and_realms(description).select do |realm, player_name|
      guild == guild_name(realm, player_name)
    rescue Exception => e
      Discordrb::LOGGER.error(e.message)
      false
    end.map(&:last)
  end
end
