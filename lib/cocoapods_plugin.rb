
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

        # These UUIDs come from the Xcode project.
        # I generated a new project a few times, and got minor changes
        # similar to what I'd expect based on a timestamp based UUID
        #
        # /* Begin PBXNativeTarget section */
        #     6042DA7C1AF34DF600070256 /* Hello */ = {
        #
        # /* Begin PBXNativeTarget section */
        #     6042DAAE1AF34E3C00070256 /* Hello */ = {
        #
        # /* Begin PBXNativeTarget section */
        #     6042DAE01AF34F0600070256 /* Hello */ = {
        #
        # /* Begin PBXNativeTarget section */
        #     6042DB121AF34F4600070256 /* Hello2 */ = {
        #
        # /* Begin PBXNativeTarget section */
        #		  6042DB441AF34F7F00070256 /* Trogdor */ = {
        # 
        # This means we send nothing remotely confidential.
        # 
        
        # I've never seen this as more than one item?
        # could be when you use `link_with` ?
        uuid = target.user_target_uuids.first
        
        analytics_targets << {
          :uuid => uuid,
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


