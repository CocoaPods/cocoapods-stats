require 'cocoapods-stats/gem_version'

module CocoaPodsStats
  Pod::HooksManager.register('cocoapods-stats', :post_install) do |context, user_options|
    require 'cocoapods'
    
    Pod::UI.section 'Sending Stats' do
    
      # Check for COCOAPODS_NO_STATS ENV var

      # Loop though all targets in the pod
      sandbox = Pod::Sandbox.new(context.sandbox_root)
      context.umbrella_targets.each do |umbrella_target|
        project = Xcodeproj::Project.open(umbrella_target.user_project_path)
        
        umbrella_target.user_target_uuids.each do |user_target_uuid|
          
          # ( UUID like - https://github.com/artsy/eigen/blob/master/Artsy.xcodeproj/project.pbxproj#L3885 )
          
          # Create an event
          # It should look something like per target:
          # [ { :target_uuid => "UUID", :pods => [all_pods_from_cocoapods_specs] }
          #   { :target_uuid => "UUID", :pods => [all_pods_from_cocoapods_specs] } ]
          #
          # I think it makes sense to make a pod:
          #   { :name => "pod.name", :version => name }
          
          
        end
        
      end
    end
    
  end
end


