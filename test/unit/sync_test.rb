require 'test_helper'

# pushing a new profile to a remote node
# pushing updates to remote
# sharing contacts with spouse
# sharing a contact group
# sharing a set of data based on some selector/query: when a record is moved out of that set (e.g. )

describe "pushing to a remote node" do
  def create_profile
    Profile.create(:handle => 'ralphie', 'fullname' => 'Ralph Malph', :email => 'ralph@happydays.com')
  end

  before do
    @profile ||= create_profile
    @authzn ||= @profile.share(
      :namespace => '*',
      :remote => 'http://remote.example.com/',
      :title => "Placeholder",
      :allow => :all,
      :include => :all,
      :sync => :bidirectional
      )
  end

  # after(:all) do
  #   @profile.delete
  # end

  it "should initially be idle" do
    @authzn.must_be :idle?
  end

  it "should know what to sync" do
    # @authzn.namespa.must_equal @profile.root
    @profile['something'] = 'new-value'
    @profile.save
    @profile.property('something').must_be :pending?, @authzn
  end

  it "should be retained in the profile" do
    @profile.authorizations.must_equal [@authzn]
  end

  describe "once connected" do
    before do
      # mock a successful link to the remote
      @profile.sync(@authzn)
    end

    it "should record state" do
      @authzn.must_be :active?
    end

    it "should make data current" do
      @authzn.commit.must_equal @profile.last_commit
    end
  end

end
