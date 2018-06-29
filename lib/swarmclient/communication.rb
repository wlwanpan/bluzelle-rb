require 'google/protobuf'
require 'base64'
require 'websocket-client-simple'
require 'eventmachine'
require 'json'

require_relative './protobuf/bluzelle_pb'
require_relative './protobuf/database_pb'

DEFAULT_UUID = '8c073d96-7291-11e8-adc0-fa7ae01bbebc'
DEFAULT_IP = '13.78.131.94' # '127.0.0.1'
DEFAULT_PORT = 51010 # 8100

module Swarmclient
  class Communication

    attr_accessor :transaction_id_limit, :ws_set_timeout

    @transaction_id_limit = 100
    @ws_set_timeout = 5

    def initialize endpoint: DEFAULT_IP, port: DEFAULT_PORT, uuid: DEFAULT_UUID, secure: false

      @_endpoint = endpoint
      @_port = port
      @_uuid = uuid
      @_protocol_prefix = secure ? 'wss://' : 'ws://'

    end

    def create key, value
      send cmd: 'create', data: { key: key, value: value.to_s }
    end

    def read key
      send cmd: 'read', data: { key: key }
    end

    def update key, value
      send cmd: 'update', data: { key: key, value: value.to_s }
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

    def encoded_protobuf_msg cmd:, protobuf_cmd_data:
      db_msg = Database_msg.new
      db_msg.header = Database_header.new db_uuid: @_uuid, transaction_id: rand(@transaction_id_limit).to_i
      db_msg[cmd] = protobuf_cmd_data
      Database_msg.encode db_msg
    end

    def generate_req cmd:, data:
      protobuf_cmd = Object.const_get "Database_#{cmd}"
      encoded_msg = encoded_protobuf_msg cmd: cmd, protobuf_cmd_data: protobuf_cmd.new(data)
      encoded64_msg = Base64.strict_encode64 encoded_msg
      {"bzn-api": "database","msg": encoded64_msg}.to_json.to_s
    end

    def generate_endpoint
      [@_protocol_prefix, @_endpoint, ':', @_port.to_s].join('')
    end

    def send cmd:, data:
      endpoint, req = [
        generate_endpoint,
        generate_req({ cmd: cmd, data: data })
      ]

      err, res = get req: req, endpoint: endpoint
      return err if err
      raise 'No Response' if res.nil?

      db_response = Database_response.decode res

      p db_response

      if db_response.redirect
        puts 'Switching leader_host: ' + db_response.redirect.leader_name
        @_endpoint, @_port = [
          db_response.redirect.leader_host,
          db_response.redirect.leader_port
        ]

        return send cmd: cmd, data: data

      elsif db_response.resp
        return db_response.resp.error if db_response.resp.error

        case cmd
          when 'has' then db_response.resp.has
          when 'keys' then db_response.resp.keys
          else db_response.resp.value
          end

      else
        raise 'Error in Response'
      end

    end

    def get req:, endpoint:
      res, err = [nil, nil]

      begin
        EventMachine.run do
          ws = WebSocket::Client::Simple.connect endpoint

          ws.on :message do |msg|
            res = msg.data
            EventMachine::stop_event_loop
          end

          ws.on :open do
            ws.send req
          end

          ws.on :close do |e|
            EventMachine::stop_event_loop
          end

          ws.on :error do |e|
            err ||= e
            EventMachine::stop_event_loop
          end

          EventMachine::Timer.new(5) { ws.close } # not accepting @ws_set_timeout, interesting ?
        end
      rescue => e
        err = e
      end

      return [err, res]
    end

  end
end
