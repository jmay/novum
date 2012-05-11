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
    first(:conditions => {"handle" => handle}) #.andand.to_hash
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

  after_create :record_creation
  def record_creation
    Commit.create(:profile => self)
  end

  around_update :record_update
  def record_update
    yield
    if changes.any?
      # only record a commit if a property changed
      Commit.create(:profile => self, :changes => changes)
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

  # def commits
  #   Changes.for(self)
  # end
end
