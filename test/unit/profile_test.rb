require 'test_helper'

describe "empty database" do
  it "should have no profiles" do
    Profile.all.to_a.must_be_empty
  end

  it "should not find anything by name" do
    Profile['ralphie'].must_be_nil
  end
end

describe "newly-created profile" do
  before do
    @ralph ||= Profile.create(:handle => 'ralphie', 'fullname' => 'Ralph Malph', :email => 'ralph@happydays.com')
    @guid = @ralph.guid
  end

  # after_tests do
  #   @ralph.delete
  # end

  it "should appear in the catalog" do
    Profile.all.must_include(@ralph) #1
    # profiles = Profile.all
    # puts profiles.to_a
    # profiles.count.must_equal 1
    # p = Profile.first
    # p[:handle].must_equal 'ralphie'
  end

  it "should be findable" do
    @guid.wont_be_nil
    matches = Profile.where(guid: @guid)
    matches.count.must_equal 1
    profile = matches.first
    profile[:handle].must_equal 'ralphie'
    profile[:fullname].must_equal 'Ralph Malph'
  end

  it "should have minimal change log" do
    @ralph.commits.count.must_equal 1
  end

  it "should have a single initial commit" do
    @ralph.commits.count.must_equal 1
  end

  it "should store properties separately, not in the main record" do
    @ralph.attributes.keys.to_set.must_equal ['_id', '_creation_commit', 'guid'].to_set
  end

  it "should have the initial properties" do
    @ralph.properties.map(&:name).to_set.must_equal ['handle', 'fullname', 'email'].to_set
    @ralph['actor'].must_be_nil
  end

  it "all the properties should have the same commit" do
    propcommits = @ralph.properties.map(&:commit).uniq
    propcommits.count.must_equal 1
    propcommits.first.must_equal @ralph.commits.first
  end
end

describe "profile changes" do
  def create_potsie
    @created ||= begin
      p = Profile.create(:handle => 'potsie', :fullname => 'Warren Weber', :email => 'potsie@happydays.com')
      # sleep 1
      p[:fullname] = 'Warren "Potsie" Weber'
      p.save
      p
    end
  end

  before do
    @potsie ||= create_potsie
  end

  # after(:all) do
  #   @potsie.delete
  # end

  it "should see the changes" do
    @potsie['fullname'].must_equal 'Warren "Potsie" Weber'
  end

  it "should remember history" do
    @potsie.commits.count.must_equal 2
  end

  it "should have multiple versions of properties" do
    @potsie.properties.count.must_equal 4
    @potsie.properties.current.count.must_equal 3
  end
end

describe "profile with a null change" do
  def create_potsie
    @created ||= begin
      p = Profile.create(:handle => 'potsie', :fullname => 'Warren Weber', :email => 'potsie@happydays.com')
      # sleep 1
      p[:fullname] = 'Warren Weber'
      p.save
      p
    end
  end

  before do
    @potsie ||= create_potsie
  end

  # after(:all) do
  #   @potsie.delete
  # end

  it "should not create an extra commit" do
    @potsie.commits.count.must_equal 1
    @potsie.properties.count.must_equal 3
    @potsie.properties.current.count.must_equal 3
  end
end

describe "profile with multi-valued properties" do
  before do
    @profile ||= begin
      p = Profile.create(:fullname => 'Jason May')
      p[:email] = ['jason@example.com', 'jmay@elsewhere.org']
      p.save
      p
    end
  end

  # after(:all) do
  #   @profile.delete
  # end

  it "should have the values in a single property" do
    @profile.commits.count.must_equal 2
    @profile.properties.count.must_equal 2
    @profile[:email].must_equal ['jason@example.com', 'jmay@elsewhere.org']
  end
end
