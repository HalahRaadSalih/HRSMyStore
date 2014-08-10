//
//  DeviceViewController.m
//  MyStore
//
//  Created by Simon on 9/12/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "DeviceViewController.h"
#import "DeviceDetailViewController.h"
#import "Device.h"
#import "Photo.h"
#import "SearchViewController.h"
#import "SwipeableCellTableViewCell.h"


#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)



@interface DeviceViewController () <SwipeableCellDelegate>
@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;

@end

@implementation DeviceViewController
@synthesize selectedRowIndex;

-(NSManagedObjectContext *) managedObjectContext
{
    NSManagedObjectContext *context=nil;
    id delegate=[[UIApplication sharedApplication] delegate];
    if([delegate performSelector:@selector(managedObjectContext)])
    {
        context=[delegate managedObjectContext];
    }
    return context;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cellsCurrentlyEditing = [NSMutableSet new];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void) viewDidAppear:(BOOL)animated
{
    NSManagedObjectContext *context=[self managedObjectContext];
    
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] initWithEntityName:@"Device"];
    self.devices=[[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
                  
    
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    SwipeableCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    

//#ifdef DEBUG
//    NSLog(@"Cell recursive description:\n\n%@\n\n", [cell performSelector:@selector(recursiveDescription)]);
//#endif
    // Configure the cell...
    NSLog(@"indexPath %@", [[self.devices objectAtIndex:indexPath.row] valueForKey:@"name"]);
    
    Device *device=[self.devices objectAtIndex:indexPath.row];
    cell.itemText=[NSString stringWithFormat:@"%@ %@", device.name, device.version];
   // BOOL isAva=[device.available boolValue];
  //  [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", device.name, device.version]];
   // [cell.detailTextLabel setText:device.company];
   // cell.imageView.image=device.thumbnail;
    
  // cell.backgroundColor=isAva? [UIColor greenColor]: [UIColor redColor];
    cell.delegate=self;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context=[self managedObjectContext];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [context deleteObject:[self.devices objectAtIndex:indexPath.row]];
        NSError *error=nil;
        if(![context save:&error])
        {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        [self.devices removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     
     */
    self.selectedRowIndex = indexPath ;
    [tableView beginUpdates];
    [tableView endUpdates];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(selectedRowIndex && indexPath.row == selectedRowIndex.row) {
        return 100;
    }
    return 44;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"UpdateDevice"])
    {
        Device *selectedDevice=[self.devices objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        DeviceDetailViewController *destinationViewController=segue.destinationViewController;
        destinationViewController.device=selectedDevice;
    }
    if([[segue identifier]  isEqualToString:@"OpenSearch"])
    {
        SearchViewController *searchViewController=[[SearchViewController alloc] init];
        searchViewController.managedObjectContext=[self managedObjectContext];
        
    }
}
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    // Fade out the view right away
    /*[UIView animateWithDuration:1.0
                          delay: .1 * indexPath.row
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                        CGAffineTransform xtransition=CGAffineTransformMakeTranslation(-320, CGAffineTransformIdentity.ty);
                         cell.transform=xtransition;
                         
                     }
                     completion:^(BOOL finished){
                         // Wait one second and then fade in the view
                         [UIView animateWithDuration:.1
                                               delay: .0
                                             options:UIViewAnimationOptionTransitionFlipFromLeft
                                          animations:^{
                                                         CGAffineTransform xtransition=CGAffineTransformMakeTranslation(-310, CGAffineTransformIdentity.ty);

                                            cell.transform=xtransition;
                                         
                                          }
                                          completion:^(BOOL finished){
                                              [UIView animateWithDuration:.1
                                                                    delay: 0.0
                                                                  options:UIViewAnimationOptionTransitionNone
                                                               animations:^{
                                                                   
                                                                   CGAffineTransform xtransition=CGAffineTransformMakeTranslation(-320, CGAffineTransformIdentity.ty);
                                                                   
                                                                  cell.transform=xtransition;
                                                                
                                                                   
                                                               }
                                                               completion:nil];
                                              }];
                     }];*/
    //1. Setup the CATransform3D structure
    CATransform3D rotation;
    rotation=CATransform3DMakeRotation((45 * 0 * M_PI)/180, 0.0, 0.7, 0.4);
    
    rotation.m34=1.0/-600;
    
    //2. Define the indial state (before the animation)
    cell.layer.shadowColor=[[UIColor blackColor] CGColor];
    cell.layer.shadowOffset=CGSizeMake(10, 10);
    cell.alpha=0;
    
    cell.layer.transform=rotation;
    cell.layer.anchorPoint=CGPointMake(0,0.5);
    
    if(cell.layer.position.x != 0){
        cell.layer.position = CGPointMake(0, cell.layer.position.y);
    }
    
    // 3. Define the final state after the animation
    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:0.8];
    cell.layer.transform=CATransform3DIdentity;
    cell.alpha=1;
    cell.layer.shadowOffset=CGSizeMake(0, 0);
    [UIView commitAnimations];

    
   
    
    }

#pragma mark - SwipeableCellDelegate
- (void)buttonOneActionForItemText:(NSString *)itemText {
    NSLog(@"In the delegate, Clicked button one for %@", itemText);
}

- (void)buttonTwoActionForItemText:(NSString *)itemText {
    NSLog(@"In the delegate, Clicked button two for %@", itemText);
}


- (void)cellDidOpen:(UITableViewCell *)cell {
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell {
    [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}
@end
