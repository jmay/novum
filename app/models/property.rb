class Property
  include Mongoid::Document
  belongs_to :profile
  belongs_to :commit

  field :name, type: String
  field :value
  field :ts_start, type: Time, default: -> { Time.now }
  field :ts_end, type: Time, default: nil

  scope :current, where(:ts_end => nil)

  def archive(commit)
    self[:commit_end] = commit.id
    self[:ts_end] = Time.now
    save
  end

  # `pending` means that
  # (a) this property is including the sync set for the specific authorization; and
  # (b) there have been change to this property that have not yet been transmitted to the remote.
  def pending?(auth)
    a = auth.covers(self)
    puts "COVERS? [#{a.inspect}]"
    b = self.changed_since(auth)
    puts "CHANGED? [#{b.inspect}]"
    a && b
  end

  def changed_since(auth)
    ts_start >= auth.created_at
  end
end
