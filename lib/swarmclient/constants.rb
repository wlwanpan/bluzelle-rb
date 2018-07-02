module Swarmclient
  module Constants

    ##
    # Randomly generated uuid, will add validation if not initialize in the future.
    DEFAULT_UUID = '8c073d96-7291-11e8-adc0-fa7ae01bbebc'

    ##
    # Points default ip to localhost.
    DEFAULT_IP = '127.0.0.1'

    ##
    # Points to default swarmDB port
    # For more details: https://github.com/bluzelle/swarmDB
    DEFAULT_PORT = 51010

    ##
    # Set limit in seconds per socket before raising a Timeout Error
    CONNECTION_TIMEOUT_LIMIT = 3

    ##
    # Temporary redirect attempt limit.
    # Track discussion on: https://gitter.im/bluzelle/opensource
    MAX_REDIRECT_ATTEMPT = 3

    ##
    # Not yet confirmed the randomness of db_msg.header.transaction_id
    # https://github.com/wlwanpan/swarmclient-rb/issues/4
    TRANSATION_ID_UPPER_LIMIT = 1000

  end
end