target 'BabylonDemo' do
  use_frameworks!
  pod 'R.swift'
  pod 'NotificationBannerSwift'
  pod 'RealmSwift'
  pod 'ReachabilitySwift'

  target 'BabylonDemoTests' do
    inherit! :search_paths
  end

  target 'BabylonDemoUITests' do
    inherit! :search_paths
  end

end


post_install do |installer|
    myTargets = ['R.swift.Library']

    installer.pods_project.targets.each do |target|
        if myTargets.include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end

