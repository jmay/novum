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
end
