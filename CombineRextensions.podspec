
Pod::Spec.new do |s|
    s.name             = 'CombineRextensions'
    s.version          = '0.1.7'
    s.summary          = 'Useful extensions for using CombineRex in SwiftUI, such as bindings, Views and gestures'
  
    s.homepage         = 'https://github.com/teufelaudio/CombineRextensions'
    s.license          = { :type => 'Apache', :text => '© 2021 Lautsprecher Teufel' }
    s.author           = { 'Lautsprecher Teufel' => 'apps@teufel.de' }
    s.source           = { :git => 'https://github.com/teufelaudio/CombineRextensions.git', :tag => "v#{s.version}" }
  
    s.ios.deployment_target       = '13.0'
    s.osx.deployment_target       = '10.15'
    s.watchos.deployment_target   = '6.0'
    s.tvos.deployment_target      = '14.0'
    s.swift_version               = '5.3'  
  
    s.source_files = 'Sources/**/*.swift'
  
    s.dependency 'CombineRex', '~> 0.8.6'
  end