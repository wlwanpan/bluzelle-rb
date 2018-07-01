require 'base64'
require 'json'

require_relative './proto_serializer'
require_relative './connection'

##
# Temporary redirect attempt limit.
# Track discussion on: https://gitter.im/bluzelle/opensource
MAX_REDIRECT_ATTEMPT = 3

DEFAULT_UUID = '8c073d96-7291-11e8-adc0-fa7ae01bbebc'
DEFAULT_IP = '127.0.0.1'
DEFAULT_PORT = 8100

module Swarmclient
  class Communication
    include ProtoSerializer
    include Connection

    def initialize endpoint: DEFAULT_IP, port: DEFAULT_PORT, uuid: DEFAULT_UUID, secure: false

      @_endpoint = endpoint
      @_port = port
      @_uuid = uuid
      @_protocol_prefix = secure ? 'wss://' : 'ws://'
      @_redirect_attempt = 0

    end

    def create key, value
      send_request cmd: 'create', data: { key: key, value: value.to_s }
    end

    def read key
      send_request cmd: 'read', data: { key: key }
    end

    def update key, value
      send_request cmd: 'update', data: { key: key, value: value.to_s }
    end

    def remove key
      send_request cmd: 'delete', data: { key: key }
    end

    def has key
      send_request cmd: 'has', data: { key: key }
    end

    def keys
      send_request cmd: 'keys', data: nil
    end

    def size
      send_request cmd: 'size', data: nil
    end

  private

    def generate_req **options
      db_msg = generate_db_msg options.merge db_uuid: @_uuid
      encoded_msg = encode_msg db_msg
      encoded64_msg = Base64.strict_encode64 encoded_msg

      {"bzn-api": "database","msg": encoded64_msg}.to_json
    end

    def generate_endpoint
      [@_protocol_prefix, @_endpoint, ':', @_port.to_s].join('')
    end

    def send_request **options
      raise StandardError.new "Max Leader redirect attempt reached" if @_redirect_attempt >= MAX_REDIRECT_ATTEMPT

      endpoint = generate_endpoint
      req = generate_req options

      err, res = connect_and_send req: req, endpoint: endpoint
      raise err unless err.nil?

      db_response = decode_res res

      if db_response.redirect
        puts 'Switching leader_host: ' + db_response.redirect.leader_name
        @_redirect_attempt += 1
        @_endpoint, @_port = [
          db_response.redirect.leader_host,
          db_response.redirect.leader_port,
        ]

        return send_request options

      elsif !db_response.resp.nil? && !db_response.resp.error.empty?
        raise db_response.resp.error

      else
        @_redirect_attempt = 0
        return case options[:cmd]
        when 'create', 'update', 'delete' then true
          when 'read' then db_response.resp.value
          else db_response.resp[options[:cmd]]
        end
      end

    rescue => e
      @_redirect_attempt = 0
      e.message
    end

  end
end
