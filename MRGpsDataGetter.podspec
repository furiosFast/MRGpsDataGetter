Pod::Spec.new do |spec|
  spec.name                       = 'MRGpsDataGetter'
  spec.version                    = '1.0.0'
  spec.license                    = { :type => 'MIT' }
  spec.homepage                   = 'https://github.com/furiosFast/MRGpsDataGetter'
  spec.authors                    = { 'furiosFast' => 'furios.fast@hotmail.it' }
  spec.summary                    = 'Easy access to Sun, Moon and Location informations. In addition Weather and 5 day/3 hour Forecast (5 day/3 hour through the OpenWeatherMap.org provider)'
  spec.source                     = { :git => 'https://github.com/furiosFast/MRGpsDataGetter.git', :tag => s.version }
  spec.module_name                = 'Rich'
  spec.swift_version              = '5.0'

  spec.ios.deployment_target      = '11.0'
  spec.tvos.deployment_target     = '11.0'
  spec.watchos.deployment_target  = '4.0'

  spec.swift_versions             = ['5.0']

  spec.source_files               = 'MRGpsDataGetter/**/*'

  spec.framework                  = 'CoreLocation'

  spec.dependency                 = 'Alamofire', "SwiftyJSON", "SwifterSwift"
end
