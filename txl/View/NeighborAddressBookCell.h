//
//  NeighborAddressBookCell.h
//  Neighbor
//
//  Created by 池嘉滨 on 2019/11/6.
//  Copyright © 2019 ICE-Chi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NeighborAddressBookCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *pic;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end

NS_ASSUME_NONNULL_END
