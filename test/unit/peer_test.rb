require 'test_helper'

# pushing a new profile to a remote node
# pushing updates to remote
# sharing contacts with spouse
# sharing a contact group
# sharing a set of data based on some selector/query: when a record is moved out of that set (e.g. )

describe Peer do
  before do
    @peer ||= Peer.new(:remote => 'https://remote.example.com/')
  end

  describe "before connecting" do
    it "should have no state" do
      @peer.wont_be :connected?
    end

    it "should have URI" do
      @peer.uri.wont_be_nil
    end
  end

  describe "after initial connection" do
    before do
      Faraday.expects(:new).returns(mock_connection = mock)
      mock_connection.expects(:post).returns(true)
      @connection ||= @peer.connect({:data => 123})
    end

    it "should have state" do
      @peer.must_be :connected?
    end
  end
end
