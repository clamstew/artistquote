require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    
    it "fetches api data based on an artist parameter" do
      expect(@controller).to receive(:fetch_event_api_data).with('the-bad-plus')
      expect(@controller).to receive(:process_api_data)

      get 'index', { :artist => 'the-bad-plus' }
      expect(response).to be_success
    end

    it "calculates event data based on seatgeek's api response" do
      VCR.use_cassette('bieber_events') do
        api_data = @controller.fetch_event_api_data('justin-bieber')

        data = @controller.process_api_data(api_data)
        #pending "Need to run test once with VCR first"
        expect(data).to be_a(Hash)
        expect(data[:lowest_price]).to eq(20)
        expect(data[:highest_price]).to eq(7118)
      end
    end

    it "doesn't die when the api service goes down" do
      exception = Timeout::Error.new 'Service timed out'
      expect(Net::HTTP).to receive(:get_response).and_raise(exception)

      # Makes sure the fetch method handles an exception and returns useable data anyway
      api_data = @controller.fetch_event_api_data('justin-bieber')
      expect(api_data[:events]).to eq([])
    end

  end

end
