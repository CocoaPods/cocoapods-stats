require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Stats do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ stats }).should.be.instance_of Command::Stats
      end
    end
  end
end

