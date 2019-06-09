require 'json'
package = JSON.parse(File.read('./package.json'))

Pod::Spec.new do |s|
  s.name                = "RNPermissions"
  s.version             = package["version"]
  s.description         = package["description"]
  s.summary             = package["description"]
  s.authors             = package["author"]
  s.license             = package["license"]
  s.homepage            = package["homepage"]

  s.default_subspec     = "Core"
  s.platform            = :ios, "9.0"
  s.requires_arc        = true
  s.source              = { :git => s.homepage, :tag => s.version }
  s.source_files        = "ios/*.{h,m}"

  s.subspec "Core" do |ss|
    s.dependency          "React/Core"
    ss.source_files     = "ios/*.{h,m}"
  end

  s.subspec "BluetoothPeripheral" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/BluetoothPeripheral/*.{h,m}"
  end

  s.subspec "Calendars" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/Calendars/*.{h,m}"
  end

  s.subspec "Camera" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/Camera/*.{h,m}"
  end

  s.subspec "Contacts" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/Contacts/*.{h,m}"
  end

  s.subspec "FaceID" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/FaceID/*.{h,m}"
  end

  s.subspec "LocationAlways" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/LocationAlways/*.{h,m}"
  end

  s.subspec "LocationWhenInUse" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/LocationWhenInUse/*.{h,m}"
  end

  s.subspec "MediaLibrary" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/MediaLibrary/*.{h,m}"
  end

  s.subspec "Microphone" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/Microphone/*.{h,m}"
  end

  s.subspec "Motion" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/Motion/*.{h,m}"
  end

  s.subspec "Notifications" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/Notifications/*.{h,m}"
  end

  s.subspec "PhotoLibrary" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/PhotoLibrary/*.{h,m}"
  end

  s.subspec "Reminders" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/Reminders/*.{h,m}"
  end

  s.subspec "Siri" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/Siri/*.{h,m}"
  end

  s.subspec "SpeechRecognition" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/SpeechRecognition/*.{h,m}"
  end

  s.subspec "StoreKit" do |ss|
    ss.dependency         "RNPermissions/Core"
    ss.source_files     = "ios/StoreKit/*.{h,m}"
  end
end
