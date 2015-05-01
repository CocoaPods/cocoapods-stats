
module CocoaPodsStats
    
  Pod::HooksManager.register('cocoapods-stats', :post_install) do |context, user_options|
    require 'cocoapods'
    
      Pod::UI.section 'Sending Stats' do
    
      # Allow opting out
      if ENV["DISABLE_COCOAPODS_STATS"]
        return
      end
      
      # Does the master specs repo exist?
      master_specs_repo = File.expand_path "~/.cocoapods/repos/master"
      unless File.directory? master_specs_repo
        return
      end

      # Is the master specs repo actually the CocoaPods OSS one?      
      Dir.chdir master_specs_repo do
        git_remote_details = `git remote -v`
        unless git_remote_details.include? "CocoaPods/Specs"
          return
        end
      end

      # Loop though all targets in the pod
      # generate a collection of hashes
      
      targets = context.umbrella_targets.map do |target|
        root_specs = target.specs.map(&:root).uniq
        
        # As it's hard to look up the source of a pod, we
        # can check if the pod exists in the master specs repo though
        
        pods = root_specs.select do |spec|
          File.directory? File.join(master_specs_repo, "Specs", spec.name)
        end.map do |spec|
          { :name => spec.name, :version => spec.version.to_s }
        end
            
        analytics_targets << {
          :uuid => target.user_target_uuids.first,
          :pods => pods
        }
      end
      
      # We need to make them unique per target UUID, config based pods
      # will throw this off. I feel like the answer is to merge all pods
      # per each target to make it one covering all cases.
      
      puts targets
      
      # Send the analytics stuff up
    end
  end
end


