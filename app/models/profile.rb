# class Profile
#   include Mongoid::Document

#   def self.[](handle)
#     conn = Mongo::Connection.new
#     conn['novum']
#     where(handle: handle).first
#   end

#   def stripped
#     attributes.reject {|k,v| v.nil?}
#   end
# end



class Profile
  include Mongoid::Document
  has_many :commits, :dependent => :delete
  has_many :properties, :dependent => :delete
  has_many :authorizations, :dependent => :delete

  attr_reader :incoming

  after_initialize :setup

  field :guid, type: String

  # attr_reader :id

  # def self.mongo
  #   @@mongo ||= Mongo::Connection.new
  # end

  # def self.db
  #   @@db ||= mongo["novum_#{Rails.env}"]
  # end

  # def self.all
  #   db['profiles'].find().to_a
  #   # dbs = mongo.database_names
  #   # dbs.select {|n| n =~ /^novum:/}.map {|n| n.gsub(/^novum:/, '')}
  # end

  def self.[](handle)
    Property.current.where(:name => 'handle', :value => handle).first.andand.profile
    # first(:conditions => {"handle" => handle}) #.andand.to_hash
    # # dbname = "novum:#{handle}"
    # # new(mongo[dbname])
    # profiles = db['profiles']
    # profiles.find_one("handle" => handle).andand.to_hash
  end

  # def self.create(hash)
  #   p = new
  #   p.set_properties(hash)
  #   p
  # end

  def self.create(hash)
    profile = super()
    profile.setup
    commit = Commit.create(:profile => profile)
    hash.each do |k,v|
      if k != '_id'
        Property.create(:profile => profile, :name => k, :value => v, :commit => commit.id)
      end
    end
    profile.guid = profile.id.to_s
    profile[:_creation_commit] = commit.id
    profile.save
    profile
  end

  def setup
    @incoming = {}
  end

  # around_create :record_creation
  def record_creation
    commit = Commit.create(:profile => self)
    attributes.each do |k,v|
      if k != '_id'
        Property.create(:profile => self, :name => k, :value => v, :commit => commit.id)
      end
    end
  end

  # around_update :record_update
  # def record_update
  #   yield
  #   pbefore = properties.current.
  #   if changes.any?
  #     puts "CHANGES: #{changes.inspect}"
  #     # only record a commit if a property changed
  #     commit = Commit.create(:profile => self, :changes => changes)
  #     changes.each do |k,(vbefore,vafter)|
  #       if prop = property(k)
  #         prop.archive(commit)
  #       end
  #       Property.create(:profile => self, :name => k, :value => vafter, :commit => commit.id)
  #     end
  #     reload_relations
  #   end
  # end
  after_update :record_update
  def record_update
    current = properties.current.each_with_object({}) {|prop,h| h[prop.name] = prop.value}
    to_save = incoming.keep_if {|k,v| current[k] != v}
    if to_save.any?
      commit = Commit.create(:profile => self, :changes => to_save)
      to_save.each do |k,v|
        if prop = property(k)
          prop.archive(commit)
        end
        Property.create(:profile => self, :name => k, :value => v, :commit => commit.id)
      end
    end
  end

  def property(key)
    current = properties.current.where(:name => key)
    raise "multiple (#{current.count}) conflicting values for #{key}" if current.count > 1
    current.first
  end

  def [](key)
    property(key).andand.value
  end

  def []=(key, value)
    if key =~ /^_/
      super
    else
      @incoming[key.to_s] = value
    end
  end

  # after_destroy :clear_commits
  # def clear_commits
  #   puts "CLEAR COMMITS"
  # end

  # def set_properties(hash)
  #   new_id = Profile.db['profiles'].insert(hash)
  #   @id = new_id
  #   Changes.new(self, hash)
  #   hash
  # end

  # def delete
  #   @@db['profiles'].remove({'_id' => id})
  #   @@db['changes'].remove(:profile => id)
  # end

  # def update(hash)
  #   current = @@db['profiles'].find_one('_id' => @id).andand.to_hash
  #   updates = hash.select {|k,v| current[k.to_s] != v}
  #   if updates.any?
  #     @@db['profiles'].update({'_id' => @id}, {"$set" => hash})
  #     Changes.new(self, hash)
  #     @@db['profiles'].find_one('_id' => @id).andand.to_hash
  #   end
  # end

  # def initialize
  # end

  # def core
  #   @core ||= initcore
  # end

  # def initcore
  #   coll = @db['core']
  #   if coll.count == 0
  #     coll.insert({})
  #   end
  #   coll
  # end

  # def [](key)
  #   data = @@db['profiles'].find_one('_id' => @id).andand.to_hash
  #   data[key]
  #   # core.find_one[key]
  # end

  # def []=(key, value)
  #   puts "SET #{key} = #{value} for #{id}"
  #   core.update({}, {'$set' => {key => value}})
  # end

  # def stripped
  #   core.find_one.reject {|k,v| v.nil?}
  # end

  def update_with(properties)
    properties.each do |k,v|
      if v.blank?
        # remove this attribute from the record entirely
        unset(k)
      else
        self[k] = v
      end
    end
  end

  # # list of attribute names that have values; ignore internal things like the generated _id
  # def properties
  #   attributes.keys - ['_id']
  # end

  def share(opts)
    auth = Authorization.create(opts.merge(:profile => self.id))
  end

  def root
    '.'
  end

  def last_commit
    commits.order_by([[:created_at, :desc]]).first
  end
end
