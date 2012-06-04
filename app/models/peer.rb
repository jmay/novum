require "faraday"

class Peer
  include Mongoid::Document

  field :remote, type: String

  attr_reader :connection

  def uri
    URI.parse(remote)
  end

  def connect(payload)
    @connection = Faraday.new(:url => uri) do |builder|
      builder.request  :url_encoded
      builder.response :logger
      builder.adapter  :net_http
    end
    response = connection.post '/sync/sync/sync', payload
  end

  def connected?
    !!connection
  end
end
