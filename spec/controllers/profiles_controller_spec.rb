require 'spec_helper'

# describe "GET /profiles" do
describe ProfilesController do
  it "has many" do
    get :index, :format => :json
    data = JSON.parse(response.body)
    data['profiles'].should_not be_nil
    data['profiles'].count.should == 0
  end

  # it "can find Cassie" do
  #   get :show, :id => "cass", :format => :json
  #   data = JSON.parse(response.body)
  #   puts data.inspect
  # end
end
