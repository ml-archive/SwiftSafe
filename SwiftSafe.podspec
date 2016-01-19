
Pod::Spec.new do |s|

  s.name         = "SwiftSafe"
  s.version      = "0.1"
  s.summary      = "Thread synchronization made easy."

  s.homepage     = "https://github.com/czechboy0/SwiftSafe"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Honza Dvorsky" => "https://honzadvorsky.com" }
  s.social_media_url   = "https://twitter.com/czechboy0"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/czechboy0/SwiftSafe.git", :tag => "v#{s.version}" }

  s.source_files  = "Safe/*.swift"

end
