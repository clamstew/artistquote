class HomeController < ApplicationController
  def index
    @artist = 'Bob Doe'
    api_data = fetch_event_api_data(params[:artist])
    @data = process_api_data(api_data)
  end

  def fetch_event_api_data(artist)
    response = Net::HTTP.get_response(URI('http://api.seatgeek.com/2/events?performers.slug=' + artist))
    api_data = JSON.parse response.body
  rescue Timeout::Error => e
    puts "SeatGeek api call error: #{e}"
    { :events => [] }
  end

  def process_api_data(data)
    puts "Proccessing data:"
    # Uncomment the following line when debugging:
    # pp data

    # TODO:
    lowest_price_array = []
    highest_price_array = []
    data["events"].each do |a| 
      lowest_price_array << a["stats"]["lowest_price"] if a["stats"]["lowest_price"] != nil
    end
    data["events"].each do |a| 
      highest_price_array << a["stats"]["highest_price"] if a["stats"]["lowest_price"] != nil
    end

    lowest_price_array.sort! {|a,b| a <=> b}
    highest_price_array.sort! {|a,b| b <=> a}

    lowest_price = lowest_price_array[0]
    highest_price = highest_price_array[0]
    {
      :lowest_price => lowest_price,
      :highest_price => highest_price
    }
  end
end
