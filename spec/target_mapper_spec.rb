require File.expand_path('../spec_helper', __FILE__)
require 'cocoapods_stats/target_mapper'

describe CocoaPodsStats::TargetMapper do
  describe 'pods_from_project' do
    before do
      project_target = mock
      project_target.stubs(:product_type).returns('testing')
      project_target.stubs(:platform_name).returns('test platform')

      project = mock
      project.stubs(:objects_by_uuid).returns('111222333' => project_target)
      Xcodeproj::Project.stubs(:open).returns(project)
    end

    it 'returns expected data' do
      master_pods  = Set.new(['ORStackView'])

      spec = Pod::Specification.new
      spec.name = 'ORStackView'
      spec.version = '1.1.1'

      target = mock
      target.stubs(:specs).returns([spec])
      target.stubs(:user_target_uuids).returns(['111222333'])
      target.stubs(:user_project_path).returns('/foo/bar')

      context = mock
      context.stubs(:umbrella_targets).returns([target])

      mapper = CocoaPodsStats::TargetMapper.new
      pods = mapper.pods_from_project(context, master_pods)

      pods.should == [
        {
          :uuid => 'da5511d2baa83c2e753852f1f2fba11003ed0c46c96820c7589b243a8ddb787a',
          :type => 'testing',
          :pods => [
            { :name => 'ORStackView', :version => '1.1.1' },
          ],
          :platform => 'test platform',
        }]
    end

    it 'returns no pods if it cannot find them in the master_pods set' do
      master_pods  = Set.new([''])

      spec = Pod::Specification.new
      spec.name = 'ORStackView'
      spec.version = '1.1.1'

      target = mock
      target.stubs(:specs).returns([spec])
      target.stubs(:user_target_uuids).returns(['111222333'])
      target.stubs(:user_project_path).returns('/foo/bar')

      context = mock
      context.stubs(:umbrella_targets).returns([target])

      mapper = CocoaPodsStats::TargetMapper.new
      pods = mapper.pods_from_project(context, master_pods)

      pods.should == [
        {
          :uuid => 'da5511d2baa83c2e753852f1f2fba11003ed0c46c96820c7589b243a8ddb787a',
          :type => 'testing',
          :pods => [],
          :platform => 'test platform',
        },
      ]
    end
  end
end
