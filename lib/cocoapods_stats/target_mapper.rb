require 'digest'

module CocoaPodsStats
  class TargetMapper
    def pods_from_project(context, project, master_pods)
      context.umbrella_targets.map do |target|
        root_specs = target.specs.map(&:root).uniq

        # As it's hard to look up the source of a pod, we
        # can check if the pod exists in the master specs repo though

        pods = root_specs.
          select { |spec| master_pods.include?(spec.name) }.
          map { |spec| { :name => spec.name, :version => spec.version.to_s } }

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
          :platform => project_target.platform_name,
        }
      end
    end
  end
end
