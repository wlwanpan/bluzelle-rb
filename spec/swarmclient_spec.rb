RSpec.describe Swarmclient do
  it "has a version number" do
    expect(Swarmclient::VERSION).not_to be nil
  end

  # Default to db_uuid: '8c073d96-7291-11e8-adc0-fa7ae01bbebc'
  bluzelle = Swarmclient::Communication.new endpoint: '13.78.131.94', port: 51010

  it "Swarmclient create operation" do
    random_key = SecureRandom.uuid
    random_value = SecureRandom.uuid
    bluzelle.create random_key, 'test'

    read_value = bluzelle.read(random_key)
    expect(read_value).to eq('test')

    remove_state = bluzelle.remove random_key
    expect(remove_state).to eq(nil)
  end
end
