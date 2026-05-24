Pod::Spec.new do |s|
  s.name             = 'Kiahk'
  s.version          = '0.1.4'
  s.summary          = 'Coptic calendar arithmetic — date conversion, Easter, and feast days.'
  s.description      = <<-DESC
    Pure Swift Coptic calendar library. Gregorian↔Coptic date conversion,
    Coptic Easter calculation (Meeus's Julian computus + Gregorian shift),
    fixed and moveable feast lookup, with English + Arabic localized names.
    Cross-port: identical results to the JS/Python/Go/Dart/C#/C ports against
    the shared core/test-vectors.json contract.
  DESC

  s.homepage         = 'https://github.com/amir-magdy-of-wizardlabz/kiahk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'WizardLabz' => 'noreply@wizardlabz.com' }
  s.source           = { :git => 'https://github.com/amir-magdy-of-wizardlabz/kiahk.git',
                         :tag => "v#{s.version}" }

  s.ios.deployment_target     = '13.0'
  s.osx.deployment_target     = '10.15'
  s.watchos.deployment_target = '6.0'
  s.tvos.deployment_target    = '13.0'

  # CocoaPods' swift_versions corresponds to Xcode's SWIFT_VERSION build setting,
  # which only accepts major versions (4.0, 4.2, 5.0). The code itself compiles
  # fine under Swift 5.9, 5.10, and 6.0 — they're language-mode toggles, not
  # SWIFT_VERSION values.
  s.swift_versions   = ['5.0']

  # Sources live under swift/Sources/Kiahk to preserve the multi-language
  # repo layout. CocoaPods consumers don't see the subdirectory — only the
  # built framework.
  s.source_files     = 'swift/Sources/Kiahk/**/*.swift'

  s.frameworks       = 'Foundation'
end
