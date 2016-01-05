require 'digest'
require 'xcodeproj'

module CocoaPodsStats
  class TargetMapper
    # Loop though all targets in the pod
    # generate a collection of hashes
    def pods_from_project(context, master_pods)
      context.umbrella_targets.flat_map do |target|
        root_specs = target.specs.map(&:root).uniq

        # As it's hard to look up the source of a pod, we
        # can check if the pod exists in the master specs repo though

        pods = root_specs.
          select { |spec| master_pods.include?(spec.name) }.
          map { |spec| { :name => spec.name, :version => spec.version.to_s } }

        # This will be an empty array for `integrate_targets: false` Podfiles
        target.user_targets.map do |user_target|
          # Send in a digested'd UUID anyway, a second layer
          # of misdirection can't hurt
          {
            :uuid => Digest::SHA256.hexdigest(user_target.uuid),
            :type => user_target.product_type,
            :pods => pods,
            :platform => user_target.platform_name,
          }
        end
      end
    end
  end
end
