# An AUTHORIZATION is a directive to share/synchronize some subset of
# a profile with a remote node.
# Once an Authorization is established/connected, then sharing will continue
# until the authorization is revoked.
#
# Candidate alternative names: SHARE, SYNC, SYNCHRONIZATION, SYNCRULE

class Authorization
  include Mongoid::Document
  belongs_to :profile
  belongs_to :commit

  field :namespace, type: String, :default => '.'
  field :created_at, type: DateTime, default: -> { DateTime.now }
  field :remote, type: String
  field :channel, type: String

  # IDLE means the authorization has not yet connected to a remote
  def idle?
    true
  end

  def active?
    false
  end

  # PENDING means there are data changes waiting to be pushed to the remote
  def pending?
    false
  end

  # hash with full specification for this authorization
  def spec
    {
      :namespace => namespace,
      :rules => 'stuff goes here'
    }
  end

  # establish a connection with a remote node, for on-going synchronization
  def connect
    # connect to peer with payload of constraint info and previous commit
    # receive response and apply to the repo

    response = peer.connect(spec)
    if response.failed?
      raise "connection attempt failed"
    end

    self.channel = response.data[:channel]
    self.save
  end

  # verify that the channel is still good for this auth, and that we can send a sync
  # TODO: what if I have changed the spec since we connected? then the auth should become inactive.
  def verify
    raise "channel not connected" unless active?

    response = peer.connect({
      :channel => channel
      })
    if response.failed?
      raise "verification attempt failed"
    end

    self[:remote_state] = response[:state]
    self.save
  end

  # execute a sync on this authorization
  # TODO: what if I have changed the spec since we connected? then the auth should become inactive.
  def sync
    raise "channel not connected" unless active?

    response = peer.connect({
      :channel => channel,
      :verified_state => self[:remote_state]
      })
    if response.failed?
      raise "sync attempt failed"
    end

    # TODO: assuming that peer does all the work & sends results synchronously.
    # Need to handle an "accepted-request-but-not-processed-it-yet" case (202 Accepted response)
    # and then do the rest of the work later.
    response.apply_deltas(response[:deltas])
  end

  def peer
    @peer ||= Peer.find_or_create_by(:remote => remote)
  end

  # is this property included in (to be synchronized for) this authorization?
  def covers(property)
    case namespace
    when '*'
      # include everything
      true
    else
      false
    end
  end

end
