require 'digest'
require 'set'
require 'rest'

module CocoaPodsStats

  class TargetMapper

    def pods_from_project context, project, master_pods
      context.umbrella_targets.map do |target|

        root_specs = target.specs.map(&:root).uniq

        # As it's hard to look up the source of a pod, we
        # can check if the pod exists in the master specs repo though

        pods = root_specs.select do |spec|
          master_pods.include?(spec.name)
        end.map do |spec|
          { :name => spec.name, :version => spec.version.to_s }
        end

        # These UUIDs come from the Xcode project
        # http://danwright.info/blog/2010/10/xcode-pbxproject-files-3/

        # I've never seen this as more than one item?
        # could be when you use `link_with`?
        uuid = target.user_target_uuids.first
        project_target = project.objects_by_uuid[uuid]

        # Send in a digested'd UUID anyway, a second layer
        # of misdirection can't hurt
        {
          :uuid => Digest::SHA256.hexdigest(uuid),
          :type => project_target.product_type,
          :pods => pods,
          :platform => project_target.platform_name
        }
      end

    end
  end

  class SpecsRepoValidator
    def validates? sources_manager
      return false unless sources_manager
      return false unless sources_manager.url.end_with? 'CocoaPods/Specs.git'
      true
    end
  end

  class OptOutValidator
    def validates?
      return false if ENV["COCOAPODS_DISABLE_STATS"]
      true
    end
  end

  Pod::HooksManager.register('cocoapods-stats', :post_install) do |context, user_options|
    require 'cocoapods'

    validator = OptOutValidator.new
    return if validator.validates?

    validator = SpecsRepoValidator.new
    return if validator.validates? Pod::SourcesManager.master.first

    Pod::UI.section 'Sending Stats' do
      master_pods = Set.new(master.pods)

      # Loop though all targets in the pod
      # generate a collection of hashes

      # We'll need this for target UUID lookup
      project = Xcodeproj::Project.open(target.user_project_path)

      mapper = TargetMapper.new
      targets = mapper.pods_from_project context, project, master_pods

      # Logs out for now:
      Pod::UI.puts targets

      # Send the analytics stuff up
      begin
        response = REST.post('http://stats-cocoapods-org.herokuapp.com/api/v1/install', {
          :targets => targets,
          :cocoapods_version => Pod::VERSION,
          :pod_try => false
        }.to_json,
        {'Accept' => 'application/json, */*', 'Content-Type' => 'application/json'})

      rescue StandardError => error
        puts error
      end

      puts response.body
    end
  end
end
