# frozen_string_literal: true

RSpec.shared_context 'aruba setup', shared_context: :aruba_setup do
  let(:binary) { ::Cloud::Kitchens::Dispatch::BINARY }
  let(:args) { [] }
  let(:command) { File.basename(binary) + ' ' + args.join(' ') }
  let(:log_file) { Tempfile.new('kitchen.log') }

  after(:each, type: :aruba) { log_file.close && log_file.unlink }

  before { run_command_and_stop(command) }

  let(:cmd) { last_command_started }

  let(:stdout) { cmd.stdout.chomp }
  let(:stderr) { cmd.stderr.chomp }
end

RSpec.configure do |rspec|
  rspec.include_context 'aruba setup', include_shared: true
end
