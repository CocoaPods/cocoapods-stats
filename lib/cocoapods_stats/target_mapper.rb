require 'digest'
require 'xcodeproj'

module CocoaPodsStats
  class TargetMapper
    # Loop though all targets in the pod
    # generate a collection of hashes
    def pods_from_project(context, master_pods)
      context.umbrella_targets.flat_map do |target|
        next unless target.user_project_path

        # These UUIDs come from the Xcode project
        # http://danwright.info/blog/2010/10/xcode-pbxproject-files-3/

        project = Xcodeproj::Project.open(target.user_project_path)
        next unless project

        root_specs = target.specs.map(&:root).uniq

        # As it's hard to look up the source of a pod, we
        # can check if the pod exists in the master specs repo though

        pods = root_specs.
          select { |spec| master_pods.include?(spec.name) }.
          map { |spec| { :name => spec.name, :version => spec.version.to_s } }

        target.user_target_uuids.map do |uuid|
          project_target = project.objects_by_uuid[uuid]

          # Send in a digested'd UUID anyway, a second layer
          # of misdirection can't hurt
          {
            :uuid => Digest::SHA256.hexdigest(uuid),
            :type => project_target.product_type,
            :pods => pods,
            :platform => project_target.platform_name,
          }
        end
      end.compact
    end
  end
end
