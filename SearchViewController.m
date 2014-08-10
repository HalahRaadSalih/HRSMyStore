//
//  SearchViewController.m
//  MyStore
//
//  Created by hala on 7/8/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "SearchViewController.h"
#import "DeviceDetailViewController.h"
@interface SearchViewController ()

@end

@implementation SearchViewController
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize managedObjectContext;
@synthesize searchBar;
@synthesize table_View;
@synthesize noResultsLabel;
@synthesize searchResults;

#pragma mark 
#pragma mark - Managed Objecet Context

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
        // Custom initialization
    }
    return self;
}

#pragma mark
#pragma mark - View Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchBar.delegate=self;
    self.table_View.delegate=self;
    self.table_View.dataSource=self;
    
    noResultsLabel=[[UILabel alloc] initWithFrame:CGRectMake(20,150,200,30)];
  //  [self.view addSubview:noResultsLabel];
    noResultsLabel.text=@"No Result";
    [noResultsLabel setHidden:YES];
    self.searchResults = [NSMutableArray arrayWithCapacity:[[self.fetchedResultsController fetchedObjects] count]];
    [self.searchBar becomeFirstResponder];
    //[self.table_View reloadData];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //[self.searchBar becomeFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark
#pragma mark - UISearchBar Methods

- (IBAction)closeSearch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{

    NSError *error;
    if(![[self fetchedResultsController] performFetch:&error ])
    {
        NSLog(@"Error in Search %@, %@",error,[error userInfo]);
        
    }
    else
    {
         self.searchBar.showsCancelButton=NO;

        //[self.searchBar resignFirstResponder];
       // [self.table_View reloadData];
        //[noResultsLabel setHidden:_fetchedResultsController.fetchedObjects.count > 0];
        
    }
}



#pragma mark
#pragma mark  - UISearchDisplayController

-(BOOL) searchDisplayController :(UISearchDisplayController *) controller shouldReloadTableForSearchString:(NSString *)searchString
{

    [self filterContentForSearchText:searchString scope:@"All"];
    return YES;
}
-(BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:@"All"];
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	NSError *error;
    if(![[self fetchedResultsController] performFetch:&error ])
    {
        NSLog(@"Error in Search %@, %@",error,[error userInfo]);
        
    }
    else
    {
        //[self.searchBar resignFirstResponder];
       //  [self.table_View reloadData];
        //[noResultsLabel setHidden:_fetchedResultsController.fetchedObjects.count > 0];
        
    }

    /*NSLog(@"Previous Search Results were removed.");
	[self.searchResults removeAllObjects];
    NSArray *fetchedObjectsArray = [[self fetchedResultsController] fetchedObjects];
    
    NSLog(@"count:%i",[fetchedObjectsArray count]);
    
	for (Device *device in fetchedObjectsArray)
	{
        NSLog(@"Adding device.name '%@' ", device.name);

        if ([scope isEqualToString:@"All"] || [device.name isEqualToString:scope])
		{
			NSComparisonResult result = [device.name compare:searchText
                                                   options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                     range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
			{
                NSLog(@"Adding device.name '%@' to searchResults as it begins with search text '%@'", device.name, searchText);
				[self.searchResults addObject:device];
            }
		}
	}*/
}

#pragma mark
#pragma mark - UITableView Methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (table_View == self.searchDisplayController.searchResultsTableView)
	{
        return [self.searchResults count];
    }
    else
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}



-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Device *device=nil;
    static NSString *CellIdentifier=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }

    if (table_View == self.searchDisplayController.searchResultsTableView)
	{
        NSLog(@"Configuring cell to show search results");
        device = [self.searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        device=[_fetchedResultsController objectAtIndexPath:indexPath];
        NSLog(@"Device name: %@", device.name);
    }
    cell.textLabel.text=device.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",device.version];
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //when a cell is selected, perform the segue
    NSLog(@"From tableView");
    [self performSegueWithIdentifier:@"OpenDeviceDetails" sender:self];

}


#pragma mark
#pragma mark - Fetched Results Controller

-(NSFetchedResultsController *) fetchedResultsController
{
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    managedObjectContext=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Device" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sort=[[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    [request setFetchBatchSize:20];
    
    NSPredicate *predicateQuery=[NSPredicate predicateWithFormat:@"name CONTAINS[c] %@",self.searchBar.text];
    [request setPredicate:predicateQuery];
    
    NSFetchedResultsController *theFetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchedResultsController=theFetchedResultsController;
    _fetchedResultsController.delegate=self;
    
    return _fetchedResultsController;
    
}

#pragma mark
#pragma mark - Prepare For Segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"OpenDeviceDetails"])
    {
        NSLog(@"From segue");
        Device *selectedDevice=[_fetchedResultsController objectAtIndexPath:[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow]];
        NSLog(@"Device Name: %@",selectedDevice.name);
        DeviceDetailViewController *destinationViewController=segue.destinationViewController;
        destinationViewController.device=selectedDevice;

    }
}


@end
