//
//  ViewController.m
//  iOS-RefreshControl
//
//  Created by Emiliano Barbosa on 8/12/15.
//  Copyright (c) 2015 Bocamuchas. All rights reserved.
//

#import "ViewController.h"

#define NUMBER_OF_SECTION_DEFAULT 1

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _items = [[NSArray alloc]initWithObjects:@"0",@"1",@"2",@"3",nil];
    _refreshControl = [[UIRefreshControl alloc]init];
    _refreshControl.backgroundColor = [UIColor purpleColor];
    _refreshControl.tintColor = [UIColor whiteColor];
    [_refreshControl addTarget:self action:@selector(fetchLastestItems) forControlEvents:UIControlEventValueChanged];
    
    [_tableView addSubview:_refreshControl];
    [_tableView sendSubviewToBack:_refreshControl];
    
}

-(void)fetchLastestItems{
    [self.tableView reloadData];
    
    if (_refreshControl) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        [_refreshControl setAttributedTitle:attributedTitle];
        [_refreshControl endRefreshing];
    }
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
    
    cell.textLabel.text = @"3";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
