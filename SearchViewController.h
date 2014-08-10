//
//  SearchViewController.h
//  MyStore
//
//  Created by hala on 7/8/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceViewController.h"
#import "DeviceDetailViewController.h"

@interface SearchViewController : UIViewController< UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,NSFetchedResultsControllerDelegate, UISearchDisplayDelegate>

@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *table_View;
@property (nonatomic, strong) UILabel *noResultsLabel;

- (IBAction)closeSearch:(id)sender;

@property (retain, nonatomic) NSMutableArray *searchResults;

@end
