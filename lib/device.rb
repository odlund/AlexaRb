require 'net/http'
require 'json'

class Device
  def initialize(id, values)
    @id = id
    @name = values["name"]
    @onUrl = URI(values["on_url"])
    @offUrl = URI(values["off_url"])
    @stateUrl = URI(values["state_url"])
  end
  
  def to_json(*a)
    {
      "manufacturername" => "Philips",
      "modelid" => "LWB004",
      "name" => @name,
      "pointsymbol" => {  "1" => "none", "2" => "none", "3" => "none", "4" => "none", "5" => "none", "6" => "none", "7" => "none", "8" => "none" },
      "state" => { "alert" => "none", "bri" => 254, "on" => @state, "reachable" => true },
      "swversion" => "66012040",
      "type" => "Dimmable Light"
    }.to_json(*a)
  end
  
  def set_state(on)
    @state = on
    if on
      Net::HTTP.get(@onUrl)
    else
      Net::HTTP.get(@offUrl)
    end
  end
  
  def get_state()
    @state = (Net::HTTP.get(@stateUrl) == "ON")
  end
  
end