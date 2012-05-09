require 'spec_helper'

describe "empty database" do
  it "should have no profiles" do
    Profile.all.should be_empty
  end

  it "should not find anything by name" do
    Profile['ralphie'].should be_nil
  end
end

describe "with a profile" do
  before(:all) do
    @profile = Profile.create(:handle => 'ralphie', :fullname => 'Ralph Malph', :email => 'ralph@happydays.com')
  end

  after(:all) do
    @profile.delete
  end

  it "should now appear in the catalog" do
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
end
