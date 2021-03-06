Pod::Spec.new do |s|
  s.name             = 'DataSorcery'
  s.version          = '0.7.3'
  s.summary          = 'Conjure UITableViews and UICollectionViews out of thin air'

  s.description      = <<-DESC
    Sorcery is an embedded DSL for declaratively constructing UITableViews and UICollectionViews.
                       DESC

  s.homepage         = 'https://github.com/adamcumiskey/Sorcery'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adam Cumiskey' => 'adam.cumiskey@gmail.com' }
  s.source           = { :git => 'https://github.com/adamcumiskey/Sorcery.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.3'
  s.swift_version = '4.0'

  s.source_files = 'DataSorcery/**/*.swift'
end
