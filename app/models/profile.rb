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
  def self.mongo
    @@mongo ||= Mongo::Connection.new
  end

  def self.db
    @@db ||= mongo["novum_#{Rails.env}"]
  end

  def self.all
    db['profiles'].find().to_a
    # dbs = mongo.database_names
    # dbs.select {|n| n =~ /^novum:/}.map {|n| n.gsub(/^novum:/, '')}
  end

  def self.[](handle)
    # dbname = "novum:#{handle}"
    # new(mongo[dbname])
    profiles = db['profiles']
    profiles.find_one("handle" => handle).andand.to_hash
  end

  def self.create(hash)
    profiles = db['profiles']
    new_id = profiles.insert(hash)
    new(new_id)
  end

  def delete
    @@db['profiles'].remove({'_id' => @id})
  end

  def update(hash)
    @@db['profiles'].update({'_id' => @id}, {"$set" => hash})
    @@db['profiles'].find_one('_id' => @id).andand.to_hash
    # puts @me.inspect
  end

  def initialize(thisid)
    @id = thisid
  end

  def core
    @core ||= initcore
  end

  def initcore
    coll = @db['core']
    if coll.count == 0
      coll.insert({})
    end
    coll
  end

  def [](key)
    data = @@db['profiles'].find_one('_id' => @id).andand.to_hash
    data[key]
    # core.find_one[key]
  end

  def []=(key, value)
    core.update({}, {'$set' => {key => value}})
  end

  def stripped
    core.find_one.reject {|k,v| v.nil?}
  end

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
end
