require 'spec_helper'

# pushing a new profile to a remote node
# pushing updates to remote
# sharing contacts with spouse

describe "pushing to a remote node" do
  def create_profile
    Profile.create(:handle => 'ralphie', 'fullname' => 'Ralph Malph', :email => 'ralph@happydays.com')
  end

  before(:all) do
    @profile = create_profile
    @authzn = @profile.share(
      :namespace => '.',
      :remote => 'http://remote.example.com/',
      :title => "Placeholder",
      :allow => :all,
      :include => :all,
      :sync => :bidirectional
      )
  end

  after(:all) do
    @profile.delete
  end

  it "should initially be idle" do
    @authzn.should be_idle
  end

  it "should know what to sync" do
    @authzn.root.should == @profile.root
    @profile['something'] = 'new-value'
    @profile.save
    @profile.property('something').should be_pending(@authzn)
  end

  it "should be retained in the profile" do
    @profile.authorizations.should == [@authzn]
  end

  describe "once connected" do
    before(:each) do
      # mock a successful link to the remote
      @authzn.connect
    end

    it "should record state" do
      @authzn.should be_connected
    end

    it "should make data current" do
      @authzn.commit.should == @profile.last_commit
    end
  end

end
