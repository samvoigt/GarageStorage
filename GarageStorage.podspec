Pod::Spec.new do |s|
  s.name             = "GarageStorage"
  s.version          = "0.1.1"
  s.summary          = "A dumb Core Data store"
  s.homepage         = "https://github.com/samvoigt/GarageStorage"
  s.license          = 'MIT'
  s.author           = { "Sam Voigt" => "sam.voigt@gmail.com" }
  s.source           = { :git => "https://github.com/samvoigt/GarageStorage.git", :tag => '0.1.1' }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'GarageStorage/Source/**/*.{h,m}', 'GarageStorage/Model/**/*.{h,m}'
  s.resource = "GarageStorage/Model/GarageStorage.xcdatamodeld"

  s.framework = 'CoreData'
end
