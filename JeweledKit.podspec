#
# Be sure to run `pod lib lint JeweledKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JeweledKit'
  s.version          = '0.1.28'
  s.summary          = 'A short description.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/cool-jeweled-moon/JeweledKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cool-jeweled-moon' => 'aneli.bob@gmail.com' }
  s.source           = { :git => 'https://github.com/cool-jeweled-moon/JeweledKit.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'
  s.ios.deployment_target = '10.0'
  
  s.default_subspecs = "Core", "UI", "Utils"
  
  s.subspec "Core" do |sp|
    sp.dependency 'JeweledKit/Utils'
    sp.source_files  = ["JeweledKit/Classes/Core/**/*"]
  end
  
  s.subspec "UI" do |sp|
    sp.dependency 'JeweledKit/Utils'
    sp.source_files  = ["JeweledKit/Classes/UI/**/*"]
  end
  
  s.subspec "Utils" do |sp|
    sp.source_files  = ["JeweledKit/Classes/Utils/**/*",
                        "JeweledKit/Classes/Extensions/**/*",
                        "JeweledKit/Classes/Constants/**/*"]
  end
end
