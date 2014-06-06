
RSpec.describe "something" do

  let(:thing) { double(:thing, update: nil) }

  let(:args1) {
    [
        "id1",
        {
          name: "Name 1",
        }
    ]
  }

  let(:args2) {
    [
        "id2",
        {
          name: "Name 2",
        }
    ]
  }

  it "asserts good" do
    thing.update(*args2)
    thing.update(*args1)
    thing.update(*args2)
    thing.update(*args1)

    expect(thing).to have_received(:update).with(*args1).at_least(:once)
  end

end
