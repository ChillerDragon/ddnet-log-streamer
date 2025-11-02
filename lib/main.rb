#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require 'rack/cors'

class LogStreamer
  def initialize(log_dir, logfile_name = "latest")
    @log_dir = log_dir
    @logfile_name = logfile_name

    @logfile_name = find_latest_log(log_dir) if @logfile_name == "latest"

    @logpath = File.join(@log_dir, @logfile_name)
  end

  def find_latest_log(_log_dir)
    raise "not implemented"
  end

  def dump(offset, num)
    lines = File.read(@logpath).split("\n")
    max = lines.count
    return { error: "offset too low" } if offset.negative?

    return { error: "offset #{offset} is bigger than max #{max}" } if offset > max

    num = max - offset if offset + num > max

    {
      offset: offset,
      num: num,
      max: lines.count,
      lines: lines[offset..(offset + num)]
    }
  end
end

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete, :options]
  end
end

get '/log' do
  streamer = LogStreamer.new("logs", "foo.txt")
  offset = params[:offset]
  num = params[:num]
  token = params[:token]

  return { error: "missing arg offset" }.to_json if offset.nil?
  return { error: "missing arg num" }.to_json if num.nil?
  return { error: "missing arg token" }.to_json if token.nil?
  return { error: "wrong token" }.to_json if token != "xxx"

  offset = offset.to_i
  num = num.to_i
  streamer.dump(offset, num).to_json
end
