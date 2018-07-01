require 'websocket-client-simple'
require 'eventmachine'

module Swarmclient
  module Connection

    private

    def connect_and_send req:, endpoint:
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

          EventMachine::Timer.new(5) { ws.close }
        end
      rescue => e
        err = e
      end

      return [err, res]
    end
  end
end