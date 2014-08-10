//
//  DeviceDetailViewController.m
//  MyStore
//
//  Created by Simon on 10/12/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "DeviceDetailViewController.h"
#import "Device.h"
#import "Photo.h"

@interface DeviceDetailViewController ()
@property (nonatomic, strong) NSString *deviceVersion;
@end

@implementation DeviceDetailViewController
@synthesize device;
@synthesize deviceNames;
@synthesize x;
@synthesize devicePicker;
@synthesize deviceImage;
@synthesize photo;
@synthesize selectedImage;
@synthesize deviceAvialableSwitch;
@synthesize isOn;
-(NSManagedObjectContext *) managedObjectContext
{
    //Retreieve the managed object context from te app delegate to use it later
    //for save and cancel methods
    NSManagedObjectContext *context=nil;
    id delegate=[[UIApplication sharedApplication] delegate];
    if([delegate performSelector:@selector(managedObjectContext)])
    {
        context=[delegate managedObjectContext];
    }
    return context;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    deviceNames=[NSArray arrayWithObjects:@"iPhone 4",@"iPhone 4s",@"iPhone 5",@"iPhone 5s", @"iPad", @"iPad Retina", nil];
    if (self.device) {
        [self.nameTextField setText:self.device.name];
        [self.versionTextField setText:self.device.version];
        [self.companyTextField setText:self.device.company];
        [self.deviceAvialableSwitch setOn:[self.device.available boolValue]];
       // if(self.photo)
        self.deviceImage.image=self.device.photo.image;
        //NSLog(@"From ViewDidLoad, Image name %@");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Save and Cancel

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    NSManagedObjectContext *context=[self managedObjectContext];

    if (self.device) {
        // Update existing device
        self.device.name=self.nameTextField.text;
        self.device.version=self.versionTextField.text;
        self.device.company=self.companyTextField.text;
        self.device.photo.image=self.deviceImage.image;
        self.device.available=[NSNumber numberWithBool:[deviceAvialableSwitch isOn] ? YES : NO];
        NSLog(@"Device Name %@",self.nameTextField.text);
        NSLog(@"Device Version %@",self.versionTextField.text);
        NSLog(@"Company Name %@",self.companyTextField.text);


        }
    else
    {
        //save new device
        Device *newDevice=[NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:context];
      //  Photo  *newPhoto= [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        newDevice.name=self.nameTextField.text;
        newDevice.version=self.versionTextField.text;
        newDevice.company=self.companyTextField.text;
        newDevice.photo.image=self.deviceImage.image;
       // newDevice.available=[NSNumber numberWithBool:isOn];
        newDevice.available=[NSNumber numberWithBool:[self readValue]];
        newDevice.available=[NSNumber numberWithBool:[deviceAvialableSwitch isOn] ? YES : NO];

        NSLog(@"Device Image %@",newDevice.photo.image);
      //  NSLog(@"From Device Details,switch is: %hhd",[newDevice.available boolValue]);
     
    }
    NSError *error=nil;
    if(![context save:&error])
    {
        NSLog(@"Saving Method Error %@ %@",error,[error localizedDescription]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark -
#pragma mark PickerView DataSource
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return deviceNames.count;
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return deviceNames[row];
}

#pragma mark -
#pragma mark PickerView Delegate

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
   // NSLog(@"row #%d",row);
    x=(int)row;
    self.versionTextField.text=deviceNames[row];
    
    
}

#pragma mark -
#pragma mark Text View Delegate
-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    //[self.view addSubview:deviceVersionPickerView];
  //  textField.inputView=deviceVersionPickerView;
}
-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}


#pragma mark -
#pragma mark Tocuhes
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    if(touch.view== deviceImage)
    {
        // openphotoalbum
        [self OpenPhotoAlbum];
    }
    
    
}

#pragma mark -
#pragma mark Photo choosing and saving methods

-(void) OpenPhotoAlbum
{
    UIImagePickerController *imagePicker=[[UIImagePickerController alloc] init];
    imagePicker.delegate=self;
    imagePicker.allowsEditing=YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];

    
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSManagedObjectContext *context=[self managedObjectContext];

    Device *photoDevice;
    //if(self.device)
        photoDevice=self.device;
   // else
     //   photoDevice=[NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:context];
    [picker  dismissViewControllerAnimated:YES completion:nil];
    selectedImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    deviceImage.image=[info objectForKey:UIImagePickerControllerOriginalImage];
   if (photoDevice.photo) {
		//[context deleteObject:device.photo];
	}
	
	// Create a new photo object and set the image.
	Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
	newPhoto.image = selectedImage;
	
	// Associate the photo object with the event.
	photoDevice.photo = newPhoto;
	
	// Create a thumbnail version of the image for the event object.
	CGSize size = selectedImage.size;
	CGFloat ratio = 0;
	if (size.width > size.height) {
		ratio = 44.0 / size.width;
	}
	else {
		ratio = 44.0 / size.height;
	}
	CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
	
	UIGraphicsBeginImageContext(rect.size);
	[selectedImage drawInRect:rect];
	device.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// Commit the change.
	NSError *error = nil;
	if (![device.managedObjectContext save:&error]) {
        NSLog(@"Image Picker Controller Error %@, %@", error, [error localizedDescription]);
	}
   // [self UpdateImageView];

}

-(void) UpdateImageView
{
    UIImage *image=self.device.photo.image;
    deviceImage.image=image;
}
- (IBAction)switchChanged:(id)sender {
    if([deviceAvialableSwitch isOn])
    {
        isOn=YES;
      //  [self saveValue];
        NSLog(@"Switch is ON");
    }
    else
    {
        isOn=NO;
      //  [self saveValue];
        NSLog(@"Switch is off");
    }
}

-(void) saveValue
{
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setBool:isOn forKey:@"switchOnOff"];
    [preferences synchronize];
}
-(BOOL)readValue  {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    return [preferences boolForKey:@"switchOnOff"];
}
@end
