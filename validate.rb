#!/usr/bin/env ruby

require 'json'
require 'faraday'
require 'faraday_middleware'
require 'pp'

failing = false
universe = JSON.parse(File.read('iiif-universe.json'))

universe['collections'].each do |collection|
  begin
    response = Faraday.new(collection['@id']) do |b|
      b.use FaradayMiddleware::FollowRedirects
      b.adapter :net_http
    end .head

    if response.status != 200
      failing = true
      $stderr.puts "Error validating: #{collection['label']}"
      $stderr.puts "#{collection['@id']} returned HTTP #{response.status}"
      PP.pp(response.headers, $stderr)
      $stderr.puts
    end
  rescue Faraday::SSLError => e
    failing = true
    $stderr.puts "Error validating: #{collection['label']}"
    $stderr.puts "#{collection['@id']} returned Faraday::SSLError"
    PP.pp(e, $stderr)
    $stderr.puts
  end
end

if failing
  exit 1
else
  exit 0
end
