class Commit
  include Mongoid::Document
  belongs_to :profile
  has_many :properties

  field :created_at, type: DateTime, default: -> { DateTime.now }

  # def self.mongo
  #   @@mongo ||= Mongo::Connection.new
  # end

  # def self.db
  #   @@db ||= mongo["novum_#{Rails.env}"]
  # end

  # def self.for(profile)
  #   Changes.db['changes'].find(:profile => profile.id)
  # end

  # def initialize(profile, hash = {})
  #   Changes.db['changes'].insert(hash.merge(:profile => profile.id))
  # end
end
