require 'digest'
require 'set'

require 'rest'

module CocoaPodsStats

  Pod::HooksManager.register('cocoapods-stats', :post_install) do |context, user_options|
    require 'cocoapods'

    # Allow opting out
    return if ENV["COCOAPODS_DISABLE_STATS"]

    Pod::UI.section 'Sending Stats' do

      master = Pod::SourcesManager.master.first
      return unless master

      return unless master.url.end_with?('CocoaPods/Specs.git')

      master_pods = Set.new(master.pods)

      # Loop though all targets in the pod
      # generate a collection of hashes

      targets = context.umbrella_targets.map do |target|
        # We'll need this for target UUID lookup
        project = Xcodeproj::Project.open(target.user_project_path)

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

      # We need to make them unique per target UUID, config based pods
      # will throw this off. I feel like the answer is to merge all pods
      # per each target to make it one covering all cases.

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
