require_relative "../../../../base"

describe "VagrantPlugins::GuestAtomic::Cap::ChangeHostName" do
  let(:described_class) do
    VagrantPlugins::GuestAtomic::Plugin
      .components
      .guest_capabilities[:atomic]
      .get(:change_host_name)
  end

  let(:machine) { double("machine") }
  let(:comm) { VagrantTests::DummyCommunicator::Communicator.new(machine) }

  before do
    allow(machine).to receive(:communicate).and_return(comm)
  end

  after do
    comm.verify_expectations!
  end

  describe ".change_host_name" do
    let(:hostname) { "banana-rama.example.com" }

    it "sets the hostname" do
      comm.stub_command("hostname | grep -w '#{hostname}'", exit_code: 1)

      described_class.change_host_name(machine, hostname)
      expect(comm.received_commands[1]).to match(/hostnamectl set-hostname '#{hostname}'/)
    end

    it "does not change the hostname if already set" do
      comm.stub_command("hostname | grep -w '#{hostname}'", exit_code: 0)
      described_class.change_host_name(machine, hostname)
      expect(comm.received_commands.size).to eq(1)
    end
  end
end
