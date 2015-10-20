//
//  ArchiveServer.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-16.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//
#import "ArchiveServer.h"
static ArchiveServer *instance = nil;
@implementation ArchiveServer

+ (ArchiveServer *)defaultArchiver
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[ArchiveServer alloc] initWithPath:F_PATH_IN_DOCUMENTS(@"Ecigarfan")];
  });
  return instance;
}

- (ArchiveServer *)initWithPath:(NSString *)path
{
  self = [super init];
  if (self) {
    self.path = path;
  }
  return self;
}

- (void)cleanAllArchiveFile {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:self.path]) {
    [fileManager removeItemAtPath:self.path error:nil];
  }
}

- (void)cleanArchiveWithKey:(NSString *)key {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *path = [self.path stringByAppendingPathComponent:key];
  if ([fileManager fileExistsAtPath:path]) {
    [fileManager removeItemAtPath:path error:nil];
  }
}

- (CGFloat)sizeOfArchiveWithKey:(NSString *)key
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *path = [self.path stringByAppendingPathComponent:key];
  if ([fileManager fileExistsAtPath:path]) {
    return [[fileManager attributesOfItemAtPath:path error:nil] fileSize];
  }
  return 0;
}

- (CGFloat)sizeOfAllArchiveFile
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:self.path]) {
    return [[fileManager attributesOfItemAtPath:self.path error:nil] fileSize];
  }
  return 0;
}

- (id)unarchiveWithKey:(NSString *)key {
    NSString * filePath = [self.path stringByAppendingPathComponent:key];
    NSData *cipher = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] AES256DecryptWithKey:@"ecigarfan"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:cipher];
}

- (void)archiveObject:(NSObject *)object key:(NSString *)key {
  @autoreleasepool {
    @synchronized (object) {
      @try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:self.path]) {
          [fileManager createDirectoryAtPath:self.path withIntermediateDirectories:NO attributes:nil error:nil];
        }
        NSString * filePath = [self.path stringByAppendingPathComponent:key];
        EcigarfanModel *model=[[EcigarfanModel alloc] initWithObject:object];
        //归档
        id objectAfter= [NSKeyedArchiver archivedDataWithRootObject:model.model];
        //AES加密
        NSData *cipher = [objectAfter AES256EncryptWithKey:@"ecigarfan"];
        [NSKeyedArchiver archiveRootObject:cipher toFile:filePath];
      }
      @catch (NSException *exception) {
        THLog(@"%@",exception.description);
      }
      @finally {
        NSLog(@"一切都结束了");
      }
    }
  }
}

@end
