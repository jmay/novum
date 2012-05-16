require 'spec_helper'

describe "empty database" do
  it "should have no profiles" do
    Profile.all.should be_empty
  end

  it "should not find anything by name" do
    Profile['ralphie'].should be_nil
  end
end

describe "newly-created profile" do
  before(:all) do
    @ralph = Profile.create(:handle => 'ralphie', 'fullname' => 'Ralph Malph', :email => 'ralph@happydays.com')
  end

  after(:all) do
    @ralph.delete
  end

  it "should appear in the catalog" do
    profiles = Profile.all
    profiles.count.should == 1
    p = profiles.first
    p[:handle].should == 'ralphie'
  end

  it "should be findable" do
    profile = Profile['ralphie']
    profile.should_not be_nil
    profile[:handle].should == 'ralphie'
    profile[:fullname].should == 'Ralph Malph'
    profile.id.should == @ralph.id
  end

  it "should have minimal change log" do
    @ralph.commits.count.should == 1
  end

  it "should have a single initial commit" do
    @ralph.commits.count.should == 1
  end

  it "should store properties separately, not in the main record" do
    @ralph.attributes.keys.should == ['_id', '_creation_commit']
  end

  it "should have the initial properties" do
    @ralph.properties.map(&:name).to_set.should == ['handle', 'fullname', 'email'].to_set
    @ralph['actor'].should be_nil
  end

  it "all the properties should have the same commit" do
    propcommits = @ralph.properties.map(&:commit).uniq
    propcommits.count.should == 1
    propcommits.first.should == @ralph.commits.first
  end
end

describe "profile changes" do
  before(:all) do
    @potsie = Profile.create(:handle => 'potsie', :fullname => 'Warren Weber', :email => 'potsie@happydays.com')
    # sleep 1
    @potsie[:fullname] = 'Warren "Potsie" Weber'
    @potsie.save
  end

  after(:all) do
    @potsie.delete
  end

  it "should see the changes" do
    @potsie['fullname'].should == 'Warren "Potsie" Weber'
  end

  it "should remember history" do
    @potsie.commits.count.should == 2
  end

  it "should have multiple versions of properties" do
    @potsie.properties.count.should == 4
    @potsie.properties.current.count.should == 3
  end
end

describe "profile with a null change" do
  before(:all) do
    @potsie = Profile.create(:handle => 'potsie', :fullname => 'Warren Weber', :email => 'potsie@happydays.com')
    # sleep 1
    @potsie[:fullname] = 'Warren Weber'
    @potsie.save
  end

  after(:all) do
    @potsie.delete
  end

  it "should not create an extra commit" do
    @potsie.commits.count.should == 1
    @potsie.properties.count.should == 3
    @potsie.properties.current.count.should == 3
  end
end

describe "profile with multi-valued properties" do
  before(:all) do
    @profile = Profile.create(:fullname => 'Jason May')
    @profile[:email] = ['jason@example.com', 'jmay@elsewhere.org']
    @profile.save
  end

  after(:all) do
    @profile.delete
  end

  it "should have the values in a single property" do
    @profile.commits.count.should == 2
    @profile.properties.count.should == 2
    @profile[:email].should == ['jason@example.com', 'jmay@elsewhere.org']
  end
end
