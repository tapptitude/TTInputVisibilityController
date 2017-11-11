Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '9.0'
s.license = 'MIT'
s.name = "TTInputVisibilityController"
s.summary = "Lightweight controller to keep your inputs visible when the keyboard is presented."
s.requires_arc = true
s.version = "0.1.0"
s.author = { "Alexandru Tudose" => "alexandru.tudose@tapptitude.com" }
s.homepage = "https://tapptitude.com/"
s.framework = "UIKit"
s.source = { :git => 'https://github.com/tapptitude/TTInputVisibilityController.git', :tag => s.version }
s.source_files = 'TTInputVisibilityController/*.{swift}'

end
