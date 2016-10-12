//
//  main.m
//  LVSourceTreeConfigCustomActions
//
//  Created by 石茗伟 on 16/10/12.
//  Copyright © 2016年 驴妈妈. All rights reserved.
//

#import <Foundation/Foundation.h>

NSMutableDictionary *getActionDic(NSString * name, NSString *params, NSString *target) {
    NSMutableDictionary *action = [NSMutableDictionary dictionaryWithDictionary:@{@"fileAction":@(0), @"logAction":@(0), @"name":name, @"params":params, @"repoAction":@(1), @"separateWindow":@(0), @"shortcutKeyCode":@"-1", @"shortcutKeyDisplay":@"", @"shortcutKeyModifiers":@(0), @"showFullOutput":@(1), @"target":target}];
    return action;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            printf("请输入一个配置自定义脚本的json文件路径\n");
            return 1;
        }
        NSError *jsonError = nil;
        NSString *jsonFilePath = [NSString stringWithFormat:@"%s", argv[1]];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonFilePath] options:NSJSONReadingMutableContainers error:&jsonError];
        if ([jsonObject isKindOfClass:[NSArray class]]) {
            NSMutableArray *actions = [NSMutableArray array];
            for (NSDictionary *actionDic in jsonObject) {
                NSString *name = [actionDic objectForKey:@"name"];
                NSString *params = [actionDic objectForKey:@"params"];
                NSString *target = [actionDic objectForKey:@"target"];
                if (!name || !params || !target) {
                    printf("获取不到应该有的参数\n");
                    return 1;
                }else {
                    [actions addObject:getActionDic(name, params, target)];
                }
            }
            NSString *configPath = [@"~/Library/Application Support/SourceTree/actions.plist" stringByStandardizingPath];
            NSMutableData *data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
            [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
            [archiver encodeObject:actions forKey:@"root"];
            [archiver finishEncoding];
            if(data) {
                BOOL result = [data writeToFile:configPath atomically:YES];
                if (result) {
                    NSArray *readActions = [NSKeyedUnarchiver unarchiveObjectWithFile:configPath];
                    printf("目前plist中已经存在的action\n%s\n", [[readActions description] UTF8String]);
                }
            } else {
                printf("写入错误\n");
            }
        }
    }
    return 0;
}
