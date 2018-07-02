require 'google/protobuf'

require_relative './constants'
require_relative './protobuf/bluzelle_pb'
require_relative './protobuf/database_pb'

module Swarmclient
  module ProtoSerializer
    include Constants

  private

    def decode_res res
      Database_response.decode res
    end

    def encode_msg msg
      bzn_msg = Bzn_msg.new db: msg
      Bzn_msg.encode bzn_msg
    end

    def generate_db_msg cmd:, data:, db_uuid:
      protobuf_cmd = cmd_to_protobuf cmd
      protobuf_cmd_msg = data.nil? ? protobuf_cmd.new : protobuf_cmd.new(data)

      proto_header_msg = Database_header.new db_uuid: db_uuid, transaction_id: rand(TRANSATION_ID_UPPER_LIMIT).to_i

      db_msg = Database_msg.new
      db_msg.header = proto_header_msg
      db_msg[cmd] = protobuf_cmd_msg
      db_msg
    end

    def cmd_to_protobuf cmd
      processed_cmd =
        case cmd
          when 'keys', 'size' then 'empty'
          else cmd
        end

      Object.const_get "Database_#{processed_cmd}"
    end

  end
end