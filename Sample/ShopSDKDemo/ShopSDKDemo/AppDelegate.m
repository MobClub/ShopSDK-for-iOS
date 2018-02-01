//
//  AppDelegate.m
//  ShopSDKDemo
//
//  Created by 陈剑东 on 2017/12/12.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "AppDelegate.h"
#import <ShopSDK/ShopSDK.h>
//ShareSDK初始化,第三方登陆使用
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

#import "WXApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import <MOBFoundation/MOBFoundation.h>

#import <ShopSDKUI/SPSDKTabBarViewController.h>

@interface AppDelegate () <WXApiDelegate>

@property (nonatomic, strong) SPSDKOrder *customPayOrder;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ShareSDK registerActivePlatforms:@[@(SSDKPlatformTypeSinaWeibo),
                                        @(SSDKPlatformTypeQQ),
                                        @(SSDKPlatformTypeWechat)]
                             onImport:^(SSDKPlatformType platformType) {
                                 
                                 switch (platformType)
                                 {
                                     case SSDKPlatformTypeWechat:
                                         [ShareSDKConnector connectWeChat:[WXApi class]];
                                         break;
                                     case SSDKPlatformTypeQQ:
                                         [ShareSDKConnector connectQQ:[QQApiInterface class]
                                                    tencentOAuthClass:[TencentOAuth class]];
                                         break;
                                     case SSDKPlatformTypeSinaWeibo:
                                         [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                                         break;
                                     default:
                                         break;
                                 }
                                 
                             }
                      onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
                          
                          switch (platformType)
                          {
                              case SSDKPlatformTypeSinaWeibo:
                                  //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                                  [appInfo SSDKSetupSinaWeiboByAppKey:@"4239321078"
                                                            appSecret:@"afe03fcc65823ebc0c0598ee8bf1aed1"
                                                          redirectUri:@"http://www.mob.com"
                                                             authType:SSDKAuthTypeBoth];
                                  break;
                              case SSDKPlatformTypeWechat:
                                  [appInfo SSDKSetupWeChatByAppId:@"wx6c033dfc1026e3cb"
                                                        appSecret:@"7bdc1d0777b3344f353d9acc54e75713"];
                                  break;
                              case SSDKPlatformTypeQQ:
                                  [appInfo SSDKSetupQQByAppId:@"1106567018"
                                                       appKey:@"KAQBQAUJcI9SoYeZ"
                                                     authType:SSDKAuthTypeBoth];
                                  break;
                              default:
                                  break;
                          }
                          
                      }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(customPay:)
                                                 name:SPSDKUINeedCustomPayNotification
                                               object:nil];
    
    
    return YES;
}


- (void)customPay:(NSNotification *)notif
{
    NSLog(@"进入自定义支付object:%@",notif.object);
    
    SPSDKOrder *order = (SPSDKOrder *)notif.object;
    self.customPayOrder = order;
    NSUInteger totalFee = order.paidMoney;
    

    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"好的"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     
                                                     //如果订单是免单的,那么则直接通知支付成功
                                                     if (order.freeOfCharge)
                                                     {
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:SPSDKUICustomPayResultNotification
                                                                                                             object:@{@"payResult":@(SPSDKClientPayStatusSuccess)}];
                                                     }
                                                     else
                                                     {
                                                         [self startWechatPrePayWithOrder:order result:^(NSDictionary *data, NSError *error) {
                                                             
                                                             if (!error)
                                                             {
                                                                 PayReq *req = [[PayReq alloc] init];
                                                                 
                                                                 req.partnerId = data[@"partnerid"];//商户id
                                                                 req.prepayId = data[@"prepayid"];//预支付id
                                                                 req.nonceStr = data[@"noncestr"];//随机串
                                                                 UInt32 timeStamp = (UInt32)([data[@"timestamp"] integerValue]);
                                                                 req.timeStamp = timeStamp;//时间戳
                                                                 req.package = data[@"package"];//
                                                                 req.sign = data[@"sign"];//签名
                                                                 NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[data objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
                                                                 [WXApi sendReq:req];
                                                                 
                                                             }
                                                             else
                                                             {
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:SPSDKUICustomPayResultNotification
                                                                                                                     object:@{@"payResult":@(SPSDKClientPayStatusFail)}];
                                                             }
                                                             
                                                             
                                                         }];
                                                     }
               
                                                 }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:SPSDKUICustomPayResultNotification
                                                                                                           object:@{@"payResult":@(SPSDKClientPayStatusCancel)}];
                                                   }];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"即将拉起支付"
                                                                   message:[NSString stringWithFormat:@"确认支付:%.2f元", totalFee / 100.f]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:sure];
    [alert addAction:cancel];
    
    [[MOBFViewController currentViewController] presentViewController:alert animated:YES completion:nil];
    
}

- (void)startWechatPrePayWithOrder:(SPSDKOrder *)order result:(void (^)(NSDictionary *data, NSError *error))result
{
    NSString *body = [NSString stringWithFormat:@"自行定制商品描述"];
    NSString *outTradeNo = [NSString stringWithFormat:@"%llu",order.orderId];
    NSUInteger totalFee = order.paidMoney;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"body"] = body;
    params[@"outTradeNo"] = outTradeNo;
    params[@"totalFee"] = @(totalFee);
    params[@"spbillCreateIp"] = [MOBFDevice ipAddress:MOBFIPVersion4];
    params[@"tradeType"] = @"APP";
    
    MOBFHttpService *service = [[MOBFHttpService alloc] initWithURLString:@"http://demopay.shop.mob.com/pay/wx/unifiedorder"];
    service.method = kMOBFHttpMethodPost;
    [service addHeaders:@{@"Content-Type":@"application/json"}];
    [service setBody:[MOBFJson jsonDataFromObject:params]];
    [service sendRequestOnResult:^(NSHTTPURLResponse *response, NSData *responseData) {
        
        NSDictionary *res = [MOBFJson objectFromJSONData:responseData];
        
        if ([res[@"success"] boolValue])
        {
            if (result)
            {
                result(res[@"data"], nil);
            }
        }
        else
        {
            if (result)
            {
                result(nil, [NSError errorWithDomain:@"ServerError" code:100 userInfo:nil]);
            }
        }
        
        
    } onFault:^(NSError *error) {
        
        if (result)
        {
            result(nil, error);
        }
        
    } onUploadProgress:nil];
    
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)onReq:(BaseReq *)req
{
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]])
    {
        if (resp.errCode == 0)
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SPSDKUICustomPayResultNotification
                                                                object:@{@"payResult":@(SPSDKClientPayStatusSuccess)}];
            
        }
    }
}

@end
