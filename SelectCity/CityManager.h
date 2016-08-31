//
//  CityManager.h
//  SelectCity
//
//  Created by 童星 on 16/8/31.
//  Copyright © 2016年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CityModel.h"

@interface CityManager : NSObject

+ (CityManager *)sharedManager;
- (BOOL)insertCaseData:(CityModel *)model;
- (NSMutableArray *)queryCase:(NSString *)sql;

@end
