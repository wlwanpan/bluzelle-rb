require 'websocket-client-simple'
require 'eventmachine'
require 'json'

DEFAULT_IP = 'ws://127.0.0.1'
DEFAULT_PORT = 8080

module Swarmclient

  class Communication

    @req_id_range = 100

    def initialize endpoint:, port:, uuid:

      @_endpoint = endpoint || DEFAULT_IP
      @_port = port || DEFAULT_PORT
      @_uuid = uuid

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
        [@_endpoint, ':', @_port.to_s].join(''),
        { "bzn-api": "crud", "cmd": cmd, "data": data, "db-uuid": @_uuid, "request-id": rand(@req_id_range) }
      ]

      raw_data = get endpoint: endpoint, req: req
      err, res = raw_data.map { |data| data ? eval(data.gsub(/\s+/, "")) : false }

      if res
        case res[:error]
          when 'NOT_THE_LEADER'

            @_endpoint, @_port = [
              "ws://#{res[:data][:'leader-host']}",
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
      else
        return err
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

      [err, res]
    end

  end

end
