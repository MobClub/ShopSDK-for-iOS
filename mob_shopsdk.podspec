Pod::Spec.new do |s|
  s.name                  = 'mob_shopsdk'
  s.version               = "1.2.0"
  s.summary               = 'mob.com 商城SDK'
  s.license               = 'Copyright © 2012-2018 mob.com'
  s.author                = { "mob" => "mobproducts@163.com" }

  s.homepage              = 'http://www.mob.com'
  s.source                = { :git => "https://github.com/MobClub/ShopSDK-for-iOS.git", :tag => s.version.to_s }
  s.platform              = :ios
  s.ios.deployment_target = "8.0"

  s.default_subspecs = 'ShopSDK'

  s.dependency 'MOBFoundation'

  #ShopSDK.framework
  s.subspec 'ShopSDK' do |sp|
    sp.vendored_frameworks = 'SDK/ShopSDK/ShopSDK.framework'
    sp.libraries           = "z", "stdc++", "icucore"
  end

  s.subspec 'ShopSDKUI' do |sp|

    sp.vendored_frameworks = 'SDK/ShopSDK/ShopSDKUI.framework'
    sp.resources           = 'SDK/ShopSDK/ShopSDKUI.xcassets','SDK/ShopSDK/ShopSDKUIXib'
    
    #mob 内部库
    sp.dependency 'mob_shopsdk/ShopSDK'
    sp.dependency 'JiMu'
    sp.dependency 'mob_umssdk'
    sp.dependency 'mob_umssdk/UMSSDKUI'
    sp.dependency 'mob_smssdk'
    sp.dependency 'mob_sharesdk'
    sp.dependency 'mob_paysdk'

    #第三方库
    sp.dependency 'IQKeyboardManager'
    sp.dependency 'MBProgressHUD'
    sp.dependency 'MJRefresh'
    sp.dependency 'SDCycleScrollView'
    sp.dependency 'SDWebImage'
    sp.dependency 'TTTAttributedLabel'
    sp.dependency 'TZImagePickerController'
    sp.dependency 'WMPageController'
    
  end


end
