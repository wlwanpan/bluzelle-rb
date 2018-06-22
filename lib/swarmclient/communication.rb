require 'google/protobuf'
require 'base64'
require 'websocket-client-simple'
require 'eventmachine'
require 'json'

require_relative './protobuf/bluzelle_pb'
require_relative './protobuf/database_pb'

DEFAULT_UUID = '8c073d96-7291-11e8-adc0-fa7ae01bbebc'
DEFAULT_IP = '127.0.0.1'
DEFAULT_PORT = 8100 # Emulator port else -> 51010

module Swarmclient
  class Communication

    attr_accessor :transaction_id_limit, :ws_set_timeout

    @transaction_id_limit = 100
    @ws_set_timeout = 750 # ms

    def initialize endpoint: DEFAULT_IP, port: DEFAULT_PORT, uuid: DEFAULT_UUID, secure: false

      @_endpoint = endpoint
      @_port = port
      @_uuid = uuid
      @_protocol_prefix = secure ? 'wss://' : 'ws://'

    end

    def create key, value
      send cmd: 'create', data: { key: key, value: value }
    end

    def read key
      send cmd: 'read', data: { key: key }
    end

    def update key, value
      send cmd: 'update', data: { key: key, value: value }
    end

    def remove key
      send cmd: 'delete', data: { key: key }
    end

    def has key
      send cmd: 'has', data: { key: key }
    end

    def keys
      send cmd: 'keys', data: nil
    end

  private

    def encoded_protobuf_msg cmd:, data:
      db_msg = Database_msg.new
      db_msg.header = Database_header.new db_uuid: @_uuid, transaction_id: rand(@transaction_id_limit).to_i
      db_msg[cmd] = data
      Database_msg.encode db_msg
    end

    def generate_req cmd:, data:
      protobuf_cmd = Object.const_get "Database_#{cmd}"
      encoded_msg = encoded_protobuf_msg cmd: cmd, data: protobuf_cmd.new(data)
      encoded64_msg = Base64.strict_encode64 encoded_msg
      output = {"bzn-api": "database","msg": encoded64_msg}.to_json.to_s # requires to_s for Js compatibility
      output
    end

    def generate_endpoint
      [@_protocol_prefix, @_endpoint, ':', @_port.to_s].join('')
    end

    def send cmd:, data:
      endpoint, req = [ generate_endpoint, generate_req({ cmd: cmd, data: data }) ]

      raw_data = get endpoint: endpoint, req: req
      err = sanitize_req raw_data[0] unless raw_data[0].nil?
      res = sanitize_req raw_data[1] unless raw_data[1].nil?

      return err unless res
      case res[:error]
        when 'NOT_THE_LEADER'
          @_endpoint, @_port = [
            res[:data][:'leader-host'].to_s,
            res[:data][:'leader-port']
          ]

          return send cmd: cmd, data: data
        when "RECORD_EXISTS", "RECORD_NOT_FOUND"
          return res[:error]
        when nil
          return res[:data]
        else
          return res[:error]
        end
    end

    def get req:, endpoint:
      res, err = [nil, nil]

      begin
        EventMachine.run do
          ws = WebSocket::Client::Simple.connect endpoint
          timer = EventMachine::Timer.new(@ws_set_timeout / 1000) { ws.close }

          ws.on :message do |msg|
            res = msg.data
            EventMachine::stop_event_loop
          end

          ws.on :open do
            ws.send req
          end

          ws.on :close do |e|
            timer.cancel unless timer.nil?
            EventMachine::stop_event_loop
          end

          ws.on :error do |e|
            err ||= e
            timer.cancel unless timer.nil?
            EventMachine::stop_event_loop
          end
        end
      rescue => e
        err = e
      end

      return [err, res]
    end

    def sanitize_req req
      return unless req.is_a? String
      eval(req.gsub(/\s+/, ''))
    end

  end
end
