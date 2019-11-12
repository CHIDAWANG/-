//
//  NeighborAddressBookModel.h
//  Neighbor
//
//  Created by 池嘉滨 on 2019/11/5.
//  Copyright © 2019 ICE-Chi. All rights reserved.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NeighborAddressBookModel : JSONModel

@property (nonatomic, copy) NSString * cell_phone;
@property (nonatomic, copy) NSString * head_images;
@property (nonatomic, copy) NSString * nick_name;

@property (nonatomic, copy) NSString *first_letter;//!< 首字母

@end

NS_ASSUME_NONNULL_END
