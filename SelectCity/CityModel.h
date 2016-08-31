//
//  CityModel.h
//  SelectCity
//
//  Created by 童星 on 16/8/25.
//  Copyright © 2016年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityModel : NSObject

@property (nonatomic, copy) NSString *code;        //城市编码
@property (nonatomic, copy) NSString *name;        //城市名称
@property (nonatomic, copy) NSString *level;       //城市等级  1，省，直辖市 2，市 3，区
@property (nonatomic, copy) NSString *pcode;       //父id

@end
