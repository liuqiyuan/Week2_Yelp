//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FiltersViewController.h"
#import "SVProgressHUD.h"
#import "MapViewController.h"
#import "MapAnnotation.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshController;

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *businessesDict;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *searchKeyword;

- (void) fetchBusinessWithQuery:(NSString *)query params:(NSDictionary *)params;

- (NSDictionary *) getDictFromSearchKeyword:(NSString *)keyword;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        [self fetchBusinessWithQuery:@"Restaurants" params:nil];
        
        self.searchKeyword = @"Chinese Restaurant";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Yelp";
    
    // Set table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    
    // Set refresh controll
    self.refreshController = [[UIRefreshControl alloc]init];
    [self.refreshController addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshController atIndex:0];
    
    // Set search bar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(self.navigationItem.titleView.frame.size.width, 0, self.navigationItem.titleView.frame.size.width, self.navigationItem.titleView.frame.size.height)];
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButtonClick)];
}

- (void) refreshPage {
    [self fetchBusinessWithQuery:@"Restaurants" params:nil];
}

// Search Bar actions
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self fetchBusinessWithQuery:@"Restaurants" params:[self getDictFromSearchKeyword:searchText]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businessesDict[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businessesDict.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.prototypeCell setBusiness:self.businessesDict[indexPath.row]];
    [self.prototypeCell layoutIfNeeded];
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Business *business = self.businessesDict[indexPath.row];
    
    MapViewController *mapVC = [[MapViewController alloc] init];
    CLLocationCoordinate2D test = CLLocationCoordinate2DMake(business.latitude,business.longitude);
    MapAnnotation *mapAnnotation = [[MapAnnotation alloc]initWithLocation:test];
    [mapAnnotation setTitle:business.name];
    [mapAnnotation setSubTitle:business.address];
    mapVC.mapAnnotation = mapAnnotation;
    [mapVC setBusiness:business];

    [self.navigationController pushViewController:mapVC animated:YES];
}

#pragma helper functions
- (NSDictionary *) getDictFromSearchKeyword:(NSString *)keyword {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    if (keyword.length > 0) {
        [filters setObject:keyword forKey:@"category_filter"];
    }
    return filters;
}

#pragma - Filter delegate method
- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    // Fire a new event
    [self fetchBusinessWithQuery:@"Restaurants" params:filters];
    NSLog(@"Applied filters: %@", filters);
}

#pragma - private method
- (void) onFilterButtonClick {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    vc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)fetchBusinessWithQuery:(NSString *)query params:(NSDictionary *)params {
    [SVProgressHUD show];
    [SVProgressHUD setBackgroundColor: [UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD showInfoWithStatus:@"Loading ..."];
    
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        //NSLog(@"response: %@", response);
        
        NSArray *businessDictResponse = response[@"businesses"];
        self.businessesDict = [Business businessesWithDicts:businessDictResponse];
        [self.tableView reloadData];
        [self.refreshController endRefreshing];
        [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

#pragma for caculating row height
- (BusinessCell *)prototypeCell {
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    }
    return _prototypeCell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
