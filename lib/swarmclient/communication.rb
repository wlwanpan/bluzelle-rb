require 'faye/websocket'
require 'eventmachine'

module Swarmclient

  class Communication

    @connected = false

    def initialize endpoint:, port:, uuid:

      @_endpoint, @_port, @_uuid = endpoint, port, uuid
      @queue = EM::Queue.new
      @_leader_endpoint = nil
      @_web_socket = nil
      @_sub_callback = nil

    end

    def connect
      @thread = Thread.start {
        EM.run {

          temp_endpoint = @connected && @_leader_endpoint.present? ? @_leader_endpoint : [@_endpoint, ':', @_port.to_s].join('')
          @_current_req = @queue.pop Proc.new { |req| req }
          @_web_socket = Faye::WebSocket::Client.new temp_endpoint

          @_spawned_process = EM.spawn do |raw_res|
            res = eval raw_res
            case res[:error]
            when 'RECORD_EXISTS', 'RECORD_NOT_FOUND', nil

              @_sub_callback.call res[:error], res[:data] if @_sub_callback.present?
              @_current_req = nil
              process_next unless @queue.empty?

            when "NOT_THE_LEADER"

              @_web_socket.send @_current_req.to_json

            end
          end

          @_web_socket.on :open do |event|
            @_leader_endpoint = temp_endpoint
            @connected = true
            @_spawned_process.notify event.data
          end

          @_web_socket.on :close do |event|
            @_web_socket = nil
            @connected = false
            @thread.join
          end

          @_web_socket.on :message do |event|
            @_spawned_process.notify(event.data)
          end

        }
      }
    end

    def close
      EM.cleanup_machine
      Thread.kill @thread
    end

    def subscribe &sub_callback
      @_sub_callback = sub_callback
    end

    def unsubscribe
      @_sub_callback = nil
    end

    def create key, value
      send cmd: 'create', data: { key: key, value: value }
      process_next
    end

    def read key
      send cmd: 'read', data: { key: key }
      process_next
    end

    def update key, value
      send cmd: 'update', data: { key: key }
      process_next
    end

    def remove key
      send cmd: 'delete', data: { key: key }
      process_next
    end

    def has key
      send cmd: 'has', data: { key: key }
      process_next
    end

    def keys
      send cmd: 'keys'
      process_next
    end

  private

    def send cmd:, data:
      @queue.push(
        {
          "bzn-api": "crud",
          "cmd": cmd,
          "data": data,
          "db-uuid": @_uuid,
          "request-id": rand(99)
        }
      )
    end

    def process_next
      return unless @_web_socket.present?
      return if @_current_req.present?
      @queue.pop do |req|
        @_current_req = req
        @_web_socket.send req.to_json
      end
    end

    def update_port port
      puts 'Changing port to:' + port
      @_port = port
    end

  end

end
