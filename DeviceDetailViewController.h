//
//  DeviceDetailViewController.h
//  MyStore
//
//  Created by Simon on 10/12/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
@interface DeviceDetailViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource, UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *versionTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyTextField;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@property (strong) Device *device;
@property (strong) Photo *photo;

@property (nonatomic, strong) NSArray *deviceNames;

-(IBAction)textFieldReturn:(id)sender;

@property (nonatomic) BOOL updatedDeviceVersionPicker;
@property (nonatomic) int x;
@property (weak, nonatomic) IBOutlet UIPickerView *devicePicker;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImage;
@property (strong, nonatomic) UIImage *selectedImage;
@property (weak, nonatomic) IBOutlet UISwitch *deviceAvialableSwitch;
- (IBAction)switchChanged:(id)sender;
@property (nonatomic) BOOL isOn;
@end
