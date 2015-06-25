#!/usr/bin/env ruby

require 'securerandom'
require 'rubygems'
require 'sinatra'
require 'ssdp'
require 'yaml'
require 'json'

options = YAML.load_file('alexa.yaml')

devices = {}
options['devices'].each_with_index { |d, index|
  devices[(index + 1).to_s] = {
    "manufacturername" => "Philips",
    "modelid" => "LWB004",
    "name" => d['name'],
    "pointsymbol" => {  "1" => "none", "2" => "none", "3" => "none", "4" => "none", "5" => "none", "6" => "none", "7" => "none", "8" => "none" },
    "state" => { "alert" => "none", "bri" => 254, "on" => false, "reachable" => true },
    "swversion" => "66012040",
    "type" => "Dimmable Light"
  }
}

settings.bind = options['host']
settings.port = options['port']

server = SSDP::Producer.new :respond_to_all => true

ssdp_options = {
  "CACHE-CONTROL" => "max-age=100",
  "LOCATION" => "http://#{settings.bind}:#{settings.port}/description.xml",
  "ST" => "upnp:rootdevice",
  "EXT" => "",
  "SERVER" =>  "FreeRTOS/7.4.2, UPnP/1.0, IpBridge/1.7.0"
}

server.add_service("urn:Belkin:device:**", ssdp_options)
server.start

put '/api/:userId/lights/:lightId/state' do
  puts "Setting Light State"
  
  body = request.body.read.to_json
  puts body["on"]
  
  content_type :json
  {}.to_json
end

get '/api/:userId/lights/:lightId' do
  puts "Requested Specific Light"
  content_type :json
  devices[params['lightId']].to_json
end

get '/api/:userId/lights' do
  puts "Requested List of Lights"
  content_type :json
  devices.to_json
end

get '/api/:userId/groups/:groupId' do
  puts "Requested Group"
  content_type :json
  {}.to_json
end

get '/api/:userId' do
  puts "Request all the Stuffs"
  content_type :json
  {}.to_json
end


get '/description.xml' do
  content_type 'text/xml'
  "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
  <root xmlns=\"urn:schemas-upnp-org:device-1-0\">
  <specVersion>
  <major>1</major>
  <minor>0</minor>
  </specVersion>
  <URLBase>http://#{settings.bind}:#{settings.port}/</URLBase>
  <device>
  <deviceType>urn:schemas-upnp-org:device:Basic:1</deviceType>
  <friendlyName>Philips hue (#{settings.bind})</friendlyName>
  <manufacturer>Royal Philips Electronics</manufacturer>
  <manufacturerURL>http://www.philips.com</manufacturerURL>
  <modelDescription>Philips hue Personal Wireless Lighting</modelDescription>
  <modelName>Philips hue bridge 2012</modelName>
  <modelNumber>929000226503</modelNumber>
  <modelURL>http://www.meethue.com</modelURL>
  <serialNumber>001788108c1c</serialNumber>
  <UDN>uuid:#{server.uuid}</UDN>
  <presentationURL>index.html</presentationURL>
  <iconList>
  <icon>
  <mimetype>image/png</mimetype>
  <height>48</height>
  <width>48</width>
  <depth>24</depth>
  <url>hue_logo_0.png</url>
  </icon>
  <icon>
  <mimetype>image/png</mimetype>
  <height>120</height>
  <width>120</width>
  <depth>24</depth>
  <url>hue_logo_3.png</url>
  </icon>
  </iconList>
  </device>
  </root>"
end