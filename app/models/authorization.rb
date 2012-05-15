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

  field :root, type: String, :default => '.'

  # IDLE means the authorization has not yet connected to a remote
  def idle?
    true
  end

  def connected?
    false
  end

  # PENDING means there are data changes waiting to be pushed to the remote
  def pending?
    false
  end

  # establish a connection with a remote node, for on-going synchronization
  def connect
    
  end
end
