module CocoaPodsStats
  class SpecsRepoValidator
    def validates?(source)
      source && source.url.end_with?('CocoaPods/Specs.git')
    end
  end

  class OptOutValidator
    def validates?
      ENV['COCOAPODS_DISABLE_STATS'].nil?
    end
  end

  Pod::HooksManager.register('cocoapods-stats', :post_install) do |context, _|
    require 'set'
    require 'cocoapods'
    require 'cocoapods_stats/target_mapper'
    require 'cocoapods_stats/sender'

    validator = OptOutValidator.new
    break unless validator.validates?

    validator = SpecsRepoValidator.new
    break unless validator.validates?(Pod::SourcesManager.master.first)

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

      is_pod_try = defined?(Pod::Command::Try::TRY_TMP_DIR) &&
        context.sandbox_root.begin_with?(Pod::Command::Try::TRY_TMP_DIR.to_s)

      # Send the analytics stuff up
      Sender.new.send(targets, :pod_try => is_pod_try)
    end
  end
end
