//
//  CityManager.m
//  SelectCity
//
//  Created by 童星 on 16/8/25.
//  Copyright © 2016年 Personal. All rights reserved.
//

#import "CityManager.h"
#import "FMDB.h"

@interface CityManager ()

@property (strong, nonatomic) FMDatabase *db;

@end

@implementation CityManager

+ (CityManager *)sharedManager{
    static CityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[CityManager alloc] init];
        if (!_sharedManager.db){
            [_sharedManager createDatabase];
            [_sharedManager createTable];
        }
    });
    return _sharedManager;
}

//创建数据库
- (void)createDatabase{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"City.db"];
    NSLog(@"%@",dbPath);
    self.db = [FMDatabase databaseWithPath:dbPath] ;
    if (![self.db open]) {
        NSLog(@"Could not open db.");
        return ;
    }
}

- (BOOL)createTable{
    return [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS CITYLIST (CODE TEXT, NAME TEXT, LEVEL TEXT, PCODE TEXT)"];
}

//插入数据
- (BOOL)insertCaseData:(CityModel *)model{
    return [self.db executeUpdate:@"INSERT INTO CITYLIST(CODE, NAME, LEVEL, PCODE) VALUES(?,?,?,?)",model.code,model.name,model.level,model.pcode];
}

//查询本地数据库中数据
- (NSMutableArray *)queryCase:(NSString *)sql{
    FMResultSet *rs = [self.db executeQuery:sql];
    NSMutableArray *listArray = [[NSMutableArray alloc] initWithCapacity:0];
    while ([rs next]) {
        CityModel *model = [[CityModel alloc] init];
        model.code = [rs stringForColumn:@"CODE"];
        model.name = [rs stringForColumn:@"NAME"];
        model.level = [rs stringForColumn:@"LEVEL"];
        model.pcode = [rs stringForColumn:@"PCODE"];
        [listArray addObject:model];
    }
    return listArray;
}

@end
