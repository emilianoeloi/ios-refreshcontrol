//
//  ViewController.m
//  iOS-RefreshControl
//
//  Created by Emiliano Barbosa on 8/12/15.
//  Copyright (c) 2015 Bocamuchas. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "CustomRefreshContent.h"

#define NUMBER_OF_SECTION_DEFAULT 1
#define API_BASE_URL @"http://service.fxos.com.br/podcasts"
#define ITEMS_API_LIMITE @100

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) CustomRefreshContent *customRefreshContent;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _refreshControl = [[UIRefreshControl alloc]init];
    _refreshControl.backgroundColor = [UIColor clearColor];
    _refreshControl.tintColor = [UIColor clearColor];
    CGRect refreshControl = CGRectMake(0, 0, self.view.bounds.size.width, _refreshControl.bounds.size.height);
    _customRefreshContent = [[CustomRefreshContent alloc]initWithFrame:refreshControl refreshingCheck:^BOOL{
        return self.refreshControl.isRefreshing;
    }];
    [_refreshControl addSubview:_customRefreshContent];
    [_refreshControl addTarget:self action:@selector(fetchLastestItems) forControlEvents:UIControlEventValueChanged];
    
    [_tableView addSubview:_refreshControl];
    [_tableView sendSubviewToBack:_refreshControl];
    
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self loadItems];
    
}

-(void)loadItems{
    NSDictionary *parameters = @{@"limit":ITEMS_API_LIMITE};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:API_BASE_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.items = responseObject;
        [self.tableView reloadData];
        double delayInSeconds = REFRESH_DELAY;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_refreshControl endRefreshing];
        });

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)fetchLastestItems{
    [self loadItems];
    [_customRefreshContent start];
}

/// http://stackoverflow.com/questions/10389476/hiding-keyboard-ios
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UIView *view in self.view.subviews){
        [view resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_items) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return NUMBER_OF_SECTION_DEFAULT;
    }else{
        UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height)];
        [messageLabel setText:@"No data"];
        [messageLabel setNumberOfLines:0];
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel sizeToFit];
        
        [_tableView setBackgroundView:messageLabel];
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"TableViewCell_ID";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *item = _items[indexPath.row];
    
    cell.textLabel.text = item[@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


/// ScrollView Delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect refreshBounds = self.refreshControl.bounds;
    CGFloat pullDistance = MAX(0.0, -_refreshControl.frame.origin.y);
    CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), 100) / 100;
    [_customRefreshContent pullAnimation:pullRatio];
    NSLog(@"===> %.02f [%.02f] [%i]", pullDistance, pullRatio, _refreshControl.isRefreshing);
}

@end
