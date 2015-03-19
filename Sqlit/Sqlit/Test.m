//
//  Test.m
//  Sqlit
//
//  Created by 丝瓜&冬瓜 on 15/3/19.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "Test.h"

@implementation Test
- (BOOL)onCreateTable:(FMDatabaseQueue *)dbQueue{
    __block BOOL result = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
//        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT,%@ TEXT PRIMARY KEY,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT)",
//                         PDB_USERTABLE,
//                         PDB_USERTABLE_secret,
//                         PDB_USERTABLE_birth,
//                         PDB_USERTABLE_company,
//                         PDB_USERTABLE_creatTime,
//                         PDB_USERTABLE_department,
//                         PDB_USERTABLE_email,
//                         PDB_USERTABLE_icon,
//                         PDB_USERTABLE_ind,
//                         PDB_USERTABLE_no,
//                         PDB_USERTABLE_name,
//                         PDB_USERTABLE_nameJp,
//                         PDB_USERTABLE_nameQp,
//                         PDB_USERTABLE_phone,
//                         PDB_USERTABLE_plateNumber,
//                         PDB_USERTABLE_post,
//                         PDB_USERTABLE_small,
//                         PDB_USERTABLE_userMobile,
//                         
//                         PDB_USERTABLE_LOGINTIME,
//                         PDB_USERTABLE_ACCOUNTSTATUS,
//                         PDB_USERTABLE_BACKGROUNDTIMESTAMP,
//                         PDB_USERTABLE_CURRENTVERSION,
//                         PDB_USERTABLE_FIRSTTIMELOGIN
//                         ];
//        
//        result = [db executeUpdate:sql];
    }];
    
    return result;

}
@end
