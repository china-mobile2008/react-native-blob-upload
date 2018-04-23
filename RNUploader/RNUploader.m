#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>

#import "RCTBridgeModule.h"
#import "RCTEventDispatcher.h"
#import "RCTLog.h"

@interface RNUploader : NSObject <RCTBridgeModule, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@end

@implementation RNUploader

@synthesize bridge = _bridge;
RCTResponseSenderBlock _callback;


RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(upload:(NSDictionary *)obj callback:(RCTResponseSenderBlock)callback)
{
    _callback = callback;
    
    NSString *uploadURL   = obj[@"url"];
    NSArray *filePath        = obj[@"filePath"];
    
    // 图片数据
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [uploadFile uploadFileWithURL:[NSURL URLWithString:uploadURL] data:data];
}

/**
 *  上传指定二进制数据
 *  @params NSURL 提交的URL
 *  @params NSData 提交的数据
 */
- (void)uploadFile:(NSURL *)url data:(NSData *)data {
    
    NSMutableString *str = [NSMutableString string];
    
    // 组合NSData数据
    NSMutableData *dataM = [NSMutableData data];
    
    // 组合二进制
    [dataM appendData:data];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:2.0];
    
    // 设置请求头，文件长度
    NSString *dataLength = [NSString stringWithFormat:@"%ld", (long)dataM.length];
    [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = dataM;
    
    request.HTTPMethod = @"POST";
    
    // 考虑到多线程
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", responseStr);
        
        _callback(@[[NSNull null], responseStr]);
    }];
}

@end
