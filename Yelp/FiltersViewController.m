//
//  FiltersViewController.m
//  Yelp
//
//  Created by Qiyuan Liu on 2/2/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"

static NSString *const SECTION_DEAL = @"DEAL";
static NSString *const SECTION_CATEGORY = @"CATEGORY";
static NSString *const SECTION_RADIUS = @"RADIUS";
static NSString *const SECTION_SORT = @"SORT";


@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>

@property (nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, readonly) NSArray *filterSectionsArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *categories;

// Selected items
// Todo: use better data structures
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, assign) BOOL selectedDeal;
@property (nonatomic, assign) BOOL selectedClosed;
@property (nonatomic, strong) NSString *selectedRadius;
@property (nonatomic, assign) BOOL selectedRadiusOn;
@property (nonatomic, assign) NSInteger selectedRadiusIndex;
@property (nonatomic, strong) NSString *selectedSort;
@property (nonatomic, assign) BOOL selectedSortOn;
@property (nonatomic, assign) NSInteger selectedSortIndex;

// Expand control
@property (nonatomic, assign) BOOL isRaduisExpanded;
@property (nonatomic, assign) BOOL isSortExpanded;
@property (nonatomic, assign) BOOL isCategoryExpanded;


- (void) initCategories;
- (NSString *) getCurrentDate;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initCategories];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButtonClick)];
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButtonClick)];
    
    self.title = @"Filters";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if (!self.selectedCategories) {
        self.selectedCategories = [[NSMutableSet alloc]init];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sectionDict = self.filterSectionsArray[indexPath.section];
    NSArray *rowArray = sectionDict[@"filters"];
    NSString *type = sectionDict[@"section"];
    
    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    
    if ([type isEqualToString:SECTION_CATEGORY]) {
        cell.titleLable.text = self.categories[indexPath.row][@"name"];
        cell.on = [self.selectedCategories containsObject:rowArray[indexPath.row]];
        cell.delegate = self;
        return cell;
    } else if ([type isEqualToString:SECTION_DEAL]) {
        cell.titleLable.text = rowArray[indexPath.row][@"name"];
        cell.on = self.selectedDeal;
        cell.delegate = self;
        return cell;
    } else if ([type isEqualToString:SECTION_RADIUS]) {
        cell.titleLable.text = rowArray[indexPath.row];
        if (indexPath.row == 0) {
            cell.on = self.isRaduisExpanded;
        } else {
            if (indexPath.row == self.selectedRadiusIndex) {
                cell.on = YES;
            } else {
                cell.on = NO;
            }
        }
        cell.delegate = self;
        return cell;
    } else if ([type isEqualToString:SECTION_SORT]) {
        cell.titleLable.text = rowArray[indexPath.row];
        if (indexPath.row == 0) {
            cell.on = self.isSortExpanded;
        } else {
            if (indexPath.row == self.selectedSortIndex) {
                cell.on = YES;
            } else {
                cell.on = NO;
            }
        }
        cell.delegate = self;
        return cell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dict = self.filterSectionsArray[section];
    NSArray *arr = dict[@"filters"];
    if (([dict[@"section"] isEqualToString:SECTION_RADIUS] && !self.isRaduisExpanded) || ([dict[@"section"] isEqualToString:SECTION_SORT] && !self.isSortExpanded)) {
        return 1;
    }
    return arr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.filterSectionsArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = self.filterSectionsArray[section][@"title"];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 38)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 38)];
    [label setFont:[UIFont boldSystemFontOfSize:18]];
    NSString *string = self.filterSectionsArray[section][@"title"];
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 3) {
        return 20;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
    
    if (section == 3) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
        [button setTitle:@"See All" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button addTarget:self action:@selector(expandCategories) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        [view setBackgroundColor:[UIColor clearColor]];
    }
    return view;
}

- (void) expandCategories {
    self.isCategoryExpanded = !self.isCategoryExpanded;
    [self.tableView reloadData];
}

#pragma - switch cell delegate methods
- (void) switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *rowArray = self.filterSectionsArray[indexPath.section][@"filters"];
    NSString *section = self.filterSectionsArray[indexPath.section][@"section"];
    if ([section isEqualToString:SECTION_DEAL]) {
        if ([rowArray[indexPath.row][@"code"] isEqualToString:@"deal"]) {
            self.selectedDeal = value;
        } else {
            self.selectedClosed = value;
        }
    } else if ([section isEqualToString:SECTION_RADIUS]) {
        self.selectedRadius = rowArray[indexPath.row];
        self.selectedRadiusOn = value;
        if (indexPath.row == 0) {
            self.isRaduisExpanded = value;
        } else if (value) {
            self.selectedRadiusIndex = indexPath.row;
        }
        [self.tableView reloadData];
    } else if ([section isEqualToString:SECTION_SORT]) {
        self.selectedSort = rowArray[indexPath.row];
        self.selectedSortOn = value;
        if (indexPath.row == 0) {
            self.isSortExpanded = value;
        } else if (value) {
            self.selectedSortIndex = indexPath.row;
        }
        [self.tableView reloadData];
    } else {
        if (value) {
            [self.selectedCategories addObject:self.categories[indexPath.row]];
        } else {
            [self.selectedCategories removeObject:self.categories[indexPath.row]];
        }
    }
}

#pragma - getter for filters
- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    if (self.selectedDeal) {
        [filters setObject:@"true" forKey:@"deals_filter"];
    }
    if (self.selectedClosed) {
        
    }
    if (self.isSortExpanded) {
        [filters setObject:[NSString stringWithFormat:@"%ld", (long)self.selectedSortIndex] forKey:@"sort"];
    }
    if (self.isRaduisExpanded) {
        [filters setObject:[NSString stringWithFormat:@"%ld", (long)self.selectedRadiusIndex * 5 * 1600] forKey:@"radius_filter"];
    }
    return filters;
}

#pragma - getter for filterSectionsArray
- (NSArray *)filterSectionsArray {
    NSMutableArray *array = [NSMutableArray array];
    NSDictionary *dealDict = @{@"title":@"Most Popular",
                               @"filters":@[
                                    @{@"name": @"Offering a Deal", @"code": @"deal"},
                                    @{@"name": [NSString stringWithFormat:@"Open Now [ %@ ]", [self getCurrentDate]], @"code": @"open"}
                                ],
                               @"section":SECTION_DEAL};
    NSDictionary *radiusDict = @{@"title":@"Radius",
                                 @"filters":@[@"Auto", @"1 mile", @"5 miles", @"10 miles", @"20 miles"],
                                 @"section":SECTION_RADIUS};
    NSDictionary *sortDict = @{@"title":@"Sort by",
                               @"filters":@[@"Best Match", @"Distance", @"Highest Rated", @"Most Reviewed"],
                               @"section":SECTION_SORT};
    NSDictionary *categoryDict = @{@"title":@"Category",
                                   @"filters":self.categories,
                                   @"section":SECTION_CATEGORY};
    
    if (!self.isCategoryExpanded) {
        NSArray *subset = [self.categories subarrayWithRange:NSMakeRange(0, 2)];
        categoryDict = @{@"title":@"Category",
                         @"filters":subset,
                         @"section":SECTION_CATEGORY};
    }
    
    [array addObject: dealDict];
    [array addObject: radiusDict];
    [array addObject:sortDict];
    [array addObject: categoryDict];
    
    return array;
}

- (NSString *) getCurrentDate {
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    return dateString;
}

- (void) onCancelButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onApplyButtonClick {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) initCategories {
    self.categories = @[@{@"name" : @"Afghan", @"code": @"afghani" },
                            @{@"name" : @"African", @"code": @"african" },
                            @{@"name" : @"American, New", @"code": @"newamerican" },
                            @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
                            @{@"name" : @"Arabian", @"code": @"arabian" },
                            @{@"name" : @"Argentine", @"code": @"argentine" },
                            @{@"name" : @"Armenian", @"code": @"armenian" },
                            @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
                            @{@"name" : @"Asturian", @"code": @"asturian" },
                            @{@"name" : @"Australian", @"code": @"australian" },
                            @{@"name" : @"Austrian", @"code": @"austrian" },
                            @{@"name" : @"Baguettes", @"code": @"baguettes" },
                            @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
                            @{@"name" : @"Barbeque", @"code": @"bbq" },
                            @{@"name" : @"Basque", @"code": @"basque" },
                            @{@"name" : @"Bavarian", @"code": @"bavarian" },
                            @{@"name" : @"Beer Garden", @"code": @"beergarden" },
                            @{@"name" : @"Beer Hall", @"code": @"beerhall" },
                            @{@"name" : @"Beisl", @"code": @"beisl" },
                            @{@"name" : @"Belgian", @"code": @"belgian" },
                            @{@"name" : @"Bistros", @"code": @"bistros" },
                            @{@"name" : @"Black Sea", @"code": @"blacksea" },
                            @{@"name" : @"Brasseries", @"code": @"brasseries" },
                            @{@"name" : @"Brazilian", @"code": @"brazilian" },
                            @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
                            @{@"name" : @"British", @"code": @"british" },
                            @{@"name" : @"Buffets", @"code": @"buffets" },
                            @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
                            @{@"name" : @"Burgers", @"code": @"burgers" },
                            @{@"name" : @"Burmese", @"code": @"burmese" },
                            @{@"name" : @"Cafes", @"code": @"cafes" },
                            @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
                            @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
                            @{@"name" : @"Cambodian", @"code": @"cambodian" },
                            @{@"name" : @"Canadian", @"code": @"New)" },
                            @{@"name" : @"Canteen", @"code": @"canteen" },
                            @{@"name" : @"Caribbean", @"code": @"caribbean" },
                            @{@"name" : @"Catalan", @"code": @"catalan" },
                            @{@"name" : @"Chech", @"code": @"chech" },
                            @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
                            @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
                            @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
                            @{@"name" : @"Chilean", @"code": @"chilean" },
                            @{@"name" : @"Chinese", @"code": @"chinese" },
                            @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
                            @{@"name" : @"Corsican", @"code": @"corsican" },
                            @{@"name" : @"Creperies", @"code": @"creperies" },
                            @{@"name" : @"Cuban", @"code": @"cuban" },
                            @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
                            @{@"name" : @"Cypriot", @"code": @"cypriot" },
                            @{@"name" : @"Czech", @"code": @"czech" },
                            @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
                            @{@"name" : @"Danish", @"code": @"danish" },
                            @{@"name" : @"Delis", @"code": @"delis" },
                            @{@"name" : @"Diners", @"code": @"diners" },
                            @{@"name" : @"Dumplings", @"code": @"dumplings" },
                            @{@"name" : @"Eastern European", @"code": @"eastern_european" },
                            @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
                            @{@"name" : @"Fast Food", @"code": @"hotdogs" },
                            @{@"name" : @"Filipino", @"code": @"filipino" },
                            @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
                            @{@"name" : @"Fondue", @"code": @"fondue" },
                            @{@"name" : @"Food Court", @"code": @"food_court" },
                            @{@"name" : @"Food Stands", @"code": @"foodstands" },
                            @{@"name" : @"French", @"code": @"french" },
                            @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
                            @{@"name" : @"Galician", @"code": @"galician" },
                            @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
                            @{@"name" : @"Georgian", @"code": @"georgian" },
                            @{@"name" : @"German", @"code": @"german" },
                            @{@"name" : @"Giblets", @"code": @"giblets" },
                            @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
                            @{@"name" : @"Greek", @"code": @"greek" },
                            @{@"name" : @"Halal", @"code": @"halal" },
                            @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
                            @{@"name" : @"Heuriger", @"code": @"heuriger" },
                            @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
                            @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
                            @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
                            @{@"name" : @"Hot Pot", @"code": @"hotpot" },
                            @{@"name" : @"Hungarian", @"code": @"hungarian" },
                            @{@"name" : @"Iberian", @"code": @"iberian" },
                            @{@"name" : @"Indian", @"code": @"indpak" },
                            @{@"name" : @"Indonesian", @"code": @"indonesian" },
                            @{@"name" : @"International", @"code": @"international" },
                            @{@"name" : @"Irish", @"code": @"irish" },
                            @{@"name" : @"Island Pub", @"code": @"island_pub" },
                            @{@"name" : @"Israeli", @"code": @"israeli" },
                            @{@"name" : @"Italian", @"code": @"italian" },
                            @{@"name" : @"Japanese", @"code": @"japanese" },
                            @{@"name" : @"Jewish", @"code": @"jewish" },
                            @{@"name" : @"Kebab", @"code": @"kebab" },
                            @{@"name" : @"Korean", @"code": @"korean" },
                            @{@"name" : @"Kosher", @"code": @"kosher" },
                            @{@"name" : @"Kurdish", @"code": @"kurdish" },
                            @{@"name" : @"Laos", @"code": @"laos" },
                            @{@"name" : @"Laotian", @"code": @"laotian" },
                            @{@"name" : @"Latin American", @"code": @"latin" },
                            @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
                            @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
                            @{@"name" : @"Malaysian", @"code": @"malaysian" },
                            @{@"name" : @"Meatballs", @"code": @"meatballs" },
                            @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
                            @{@"name" : @"Mexican", @"code": @"mexican" },
                            @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
                            @{@"name" : @"Milk Bars", @"code": @"milkbars" },
                            @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
                            @{@"name" : @"Modern European", @"code": @"modern_european" },
                            @{@"name" : @"Mongolian", @"code": @"mongolian" },
                            @{@"name" : @"Moroccan", @"code": @"moroccan" },
                            @{@"name" : @"New Zealand", @"code": @"newzealand" },
                            @{@"name" : @"Night Food", @"code": @"nightfood" },
                            @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
                            @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
                            @{@"name" : @"Oriental", @"code": @"oriental" },
                            @{@"name" : @"Pakistani", @"code": @"pakistani" },
                            @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
                            @{@"name" : @"Parma", @"code": @"parma" },
                            @{@"name" : @"Persian/Iranian", @"code": @"persian" },
                            @{@"name" : @"Peruvian", @"code": @"peruvian" },
                            @{@"name" : @"Pita", @"code": @"pita" },
                            @{@"name" : @"Pizza", @"code": @"pizza" },
                            @{@"name" : @"Polish", @"code": @"polish" },
                            @{@"name" : @"Portuguese", @"code": @"portuguese" },
                            @{@"name" : @"Potatoes", @"code": @"potatoes" },
                            @{@"name" : @"Poutineries", @"code": @"poutineries" },
                            @{@"name" : @"Pub Food", @"code": @"pubfood" },
                            @{@"name" : @"Rice", @"code": @"riceshop" },
                            @{@"name" : @"Romanian", @"code": @"romanian" },
                            @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
                            @{@"name" : @"Rumanian", @"code": @"rumanian" },
                            @{@"name" : @"Russian", @"code": @"russian" },
                            @{@"name" : @"Salad", @"code": @"salad" },
                            @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
                            @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
                            @{@"name" : @"Scottish", @"code": @"scottish" },
                            @{@"name" : @"Seafood", @"code": @"seafood" },
                            @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
                            @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
                            @{@"name" : @"Singaporean", @"code": @"singaporean" },
                            @{@"name" : @"Slovakian", @"code": @"slovakian" },
                            @{@"name" : @"Soul Food", @"code": @"soulfood" },
                            @{@"name" : @"Soup", @"code": @"soup" },
                            @{@"name" : @"Southern", @"code": @"southern" },
                            @{@"name" : @"Spanish", @"code": @"spanish" },
                            @{@"name" : @"Steakhouses", @"code": @"steak" },
                            @{@"name" : @"Sushi Bars", @"code": @"sushi" },
                            @{@"name" : @"Swabian", @"code": @"swabian" },
                            @{@"name" : @"Swedish", @"code": @"swedish" },
                            @{@"name" : @"Swiss Food", @"code": @"swissfood" },
                            @{@"name" : @"Tabernas", @"code": @"tabernas" },
                            @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
                            @{@"name" : @"Tapas Bars", @"code": @"tapas" },
                            @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
                            @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
                            @{@"name" : @"Thai", @"code": @"thai" },
                            @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
                            @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
                            @{@"name" : @"Trattorie", @"code": @"trattorie" },
                            @{@"name" : @"Turkish", @"code": @"turkish" },
                            @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
                            @{@"name" : @"Uzbek", @"code": @"uzbek" },
                            @{@"name" : @"Vegan", @"code": @"vegan" },
                            @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
                            @{@"name" : @"Venison", @"code": @"venison" },
                            @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
                            @{@"name" : @"Wok", @"code": @"wok" },
                            @{@"name" : @"Wraps", @"code": @"wraps" },
                            @{@"name" : @"Yugoslav", @"code": @"yugoslav" }];
}

@end
