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
    @ralph = Profile.create(:handle => 'ralphie', :fullname => 'Ralph Malph', :email => 'ralph@happydays.com')
  end

  after(:all) do
    @ralph.delete
  end

  it "should appear in the catalog" do
    profiles = Profile.all
    profiles.count.should == 1
    p = profiles.first
    p['handle'].should == 'ralphie'
  end

  it "should be findable" do
    profile = Profile['ralphie']
    profile.should_not be_nil
    profile['handle'].should == 'ralphie'
    profile['fullname'].should == 'Ralph Malph'
  end

  it "should have minimal change log" do
    @ralph.changes.count.should == 1
  end
end

describe "profile changes" do
  before(:all) do
    @potsie = Profile.create(:handle => 'potsie', :fullname => 'Warren Weber', :email => 'potsie@happydays.com')
  end

  before(:each) do
    @potsie.update(:fullname => 'Warren "Potsie" Weber')
  end

  after(:all) do
    @potsie.delete
  end

  it "should see the changes" do
    @potsie['fullname'].should == 'Warren "Potsie" Weber'
  end

  it "should remember history" do
    # puts @potsie.changes.to_a.inspect
    @potsie.changes.count.should == 2
  end
end
