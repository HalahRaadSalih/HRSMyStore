//
//  DeviceViewController.h
//  MyStore
//
//  Created by Simon on 9/12/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, retain) NSIndexPath *selectedRowIndex;
@end
