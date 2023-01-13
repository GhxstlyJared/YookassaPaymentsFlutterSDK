Pod::Spec.new do |s|
  s.name             = 'yookassa_payments_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Flutter SDK from yoomoney'
  s.description      = <<-DESC
Flutter SDK from yoomoney
                       DESC
  s.homepage         = 'https://yoomoney.ru'
  s.license          = { :file => '../LICENSE' }
  s.author 	    = 'YooMoney Team'
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'YooKassaPayments', '6.9.0'

  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.static_framework = true
end
