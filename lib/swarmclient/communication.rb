require 'websocket-client-simple'
require 'eventmachine'
require 'json'

DEFAULT_UUID = '8c073d96-7291-11e8-adc0-fa7ae01bbebc'
DEFAULT_IP = '127.0.0.1'
DEFAULT_PORT = 51010

module Swarmclient

  class Communication

    @req_id_limit = 100

    def initialize endpoint:, port:, uuid:, secure: false

      @_endpoint = endpoint || DEFAULT_IP
      @_port = port || DEFAULT_PORT
      @_uuid = uuid || DEFAULT_UUID
      @_protocol_prefix = secure ? 'wss://' : 'ws://'

    end

    def create key, value
      send cmd: 'create', data: { key: key, value: value }
    end

    def read key
      send cmd: 'read', data: { key: key }
    end

    def read_multiple keys
      send_multiple cmd: 'read', keys: keys
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

    def send_multiple cmd:, keys:
      keys.map do |key|
        res = send cmd: cmd, data: { key: key }
        Hash[key, res ? res[:value] : nil]
      end
    end

    def send cmd:, data:
      endpoint, req = [
        [@_protocol_prefix, @_endpoint, ':', @_port.to_s].join(''),
        { "bzn-api": "crud", "cmd": cmd, "data": data, "db-uuid": @_uuid, "request-id": rand(@req_id_limit) }
      ]

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

          ws.on :message do |msg|
            res = msg.data
            EventMachine::stop_event_loop
          end

          ws.on :open do
            ws.send req.to_json
          end

          ws.on :close do |e|
            EventMachine::stop_event_loop
          end

          ws.on :error do |e|
            err = e
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
