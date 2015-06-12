require 'rest'
require 'digest'

module CocoaPodsStats
    
  Pod::HooksManager.register('cocoapods-stats', :post_install) do |context, user_options|
    require 'cocoapods'
  
    # Allow opting out
    return if ENV["DISABLE_COCOAPODS_STATS"]
    
    Pod::UI.section 'Sending Stats' do
      
      # Does the master specs repo exist?
      master_specs_repo = File.expand_path "~/.cocoapods/repos/master"
      return unless File.directory? master_specs_repo
      
      # Is the master specs repo actually the CocoaPods OSS one?      
      Dir.chdir master_specs_repo do
        git_remote_details = `git remote -v`
        return unless git_remote_details.include? "CocoaPods/Specs"
      end

      # Loop though all targets in the pod
      # generate a collection of hashes
      
      targets = context.umbrella_targets.map do |target|
        # We'll need this for target UUID lookup
        project = Xcodeproj::Project.open(target.user_project_path)
        
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
        #    Multiple days later
        # /* Begin PBXNativeTarget section */
        #     601142661AF7CD3B00F070A5 /* Burninator */ = {
        #
        # This means we send nothing remotely confidential.
        # 
        
        # I've never seen this as more than one item?
        # could be when you use `link_with`?
        uuid = target.user_target_uuids.first
        project_target = project.objects_by_uuid[uuid]
        
        # Send in a digested'd UUID anyway, a second layer
        # of misdirection can't hurt
        {
          :uuid => Digest::SHA256.hexdigest(uuid),
          :type => project_target.product_type,
          :pods => pods
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
          :cocoapods_version => Pod::VERSION
        }.to_json,
        {'Accept' => 'application/json, */*', 'Content-Type' => 'application/json'})

      rescue StandardError => error
        puts error
      end

      puts response.body
    end
  end
end


