Pod::Spec.new do |s|
  s.name             = 'CircleProgressButton'
  s.version          = '0.5.1'
  s.summary          = 'UIView based circle button with CAShapeLayer based progress stroke'
  s.description      = <<-DESC
        'UIView based circle button with CAShapeLayer based progress stroke.'
                       DESC
  s.homepage         = 'https://github.com/toshi0383/CircleProgressButton'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'toshi0383' => 't.suzuki326@gmail.com' }
  s.source           = { :git => 'https://github.com/toshi0383/CircleProgressButton.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/toshi0383'

  s.ios.deployment_target = '9.0'

  s.source_files = 'CircleProgressButton/*.swift'
end
