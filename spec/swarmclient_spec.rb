RSpec.describe Swarmclient do
  it "has a version number" do
    expect(Swarmclient::VERSION).not_to be nil
  end

  # Default to db_uuid: '8c073d96-7291-11e8-adc0-fa7ae01bbebc'
  TESTNET_ENDPOINT = '13.78.131.94'
  TESTNET_PORT = 51010

  bluzelle = Swarmclient::Communication.new endpoint: TESTNET_ENDPOINT, port: TESTNET_PORT

  it "Basic: SIZE operation" do
    size_res = bluzelle.size
    expect(size_res.is_a?(Integer)).to eq(true)
    expect(size_res >= 0).to eq(true)
  end

  it "Basic: KEYS operation" do
    keys_res = bluzelle.keys
    expect(keys_res.is_a?(Google::Protobuf::RepeatedField)).to eq(true)
  end

  it "Basic: READ/WRITE operation of a single entry" do
    random_key = SecureRandom.uuid
    value = 'Single Entry'

    bluzelle.create random_key, value

    read_value = bluzelle.read(random_key)
    expect(read_value).to eq(value)

    bluzelle.remove random_key
  end

  it "RECORD_EXISTS: WRITE operation on the same key" do
    random_key = SecureRandom.uuid
    value = "Duplicated Record"

    bluzelle.create random_key, value
    read_value = bluzelle.read random_key
    expect(read_value).to eq(value)

    bluzelle.create random_key, value
    read_value = bluzelle.read
    expect(first_read_value).to eq("RECORD_EXISTS")

    bluzelle.remove random_key
  end

  it "RECORD_NOT_FOUND: READ/UPDATE operation on record no stored entry" do
    random_key = SecureRandom.uuid
    expected_value = "RECORD_NOT_FOUND"

    read_value = bluzelle.read random_key
    expect(read_value).to eq(expected_value)

    update_res = bluzelle.update random_key, ''
    expect(update_res).to eq(expected_value)
  end
end
