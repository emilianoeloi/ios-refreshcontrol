//
//  CustomRefreshContent.m
//  iOS-RefreshControl
//
//  Created by Emiliano Barbosa on 8/13/15.
//  Copyright (c) 2015 Bocamuchas. All rights reserved.
//

#import "CustomRefreshContent.h"

@interface CustomRefreshContent()

@property (weak, nonatomic) IBOutlet UIView *blockOne;
@property (weak, nonatomic) IBOutlet UIView *blockTwo;
@property (nonatomic, strong) LoadingAnimationBlock refreshingCheck;

@property (nonatomic) BOOL blockOneFull;
@property (nonatomic) BOOL isRefreshAnimating;
@property (nonatomic) CGFloat scaleOne;
@property (nonatomic) CGFloat scaleTwo;


@end

@implementation CustomRefreshContent

- (NSLayoutConstraint *)pin:(id)item attribute:(NSLayoutAttribute)attribute
{
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:item
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}

- (instancetype)initWithFrame:(CGRect)frame refreshingCheck:(LoadingAnimationBlock)refreshingCheck
{
    NSLog(@"%s", __FUNCTION__);
    
    self = [super initWithFrame:frame];
    if (self)
    {
        _refreshingCheck = refreshingCheck;
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSArray *loadedViews = [mainBundle loadNibNamed:@"CustomRefreshContent" owner:self options:nil];
        CustomRefreshContent *loadedSubview = [loadedViews firstObject];
        
        [self addSubview:loadedSubview];
        
        loadedSubview.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addConstraint:[self pin:loadedSubview attribute:NSLayoutAttributeTop]];
        [self addConstraint:[self pin:loadedSubview attribute:NSLayoutAttributeLeft]];
        [self addConstraint:[self pin:loadedSubview attribute:NSLayoutAttributeBottom]];
        [self addConstraint:[self pin:loadedSubview attribute:NSLayoutAttributeRight]];
        
        [_blockOne.layer setCornerRadius:CORNER_RADIUS_DEFAULT];
        [_blockTwo.layer setCornerRadius:CORNER_RADIUS_DEFAULT];
        
        [self setup];
        [self resetAnimation];
        
    }
    return self;
}

-(void)setup{
    _scaleOne = 0.0f;
    _scaleTwo = 0.0f;
}

-(void)prepareForAnimation{
    [self setNeedsLayout];
    _blockTwo.transform = CGAffineTransformMakeScale(0.0, 0.0);
    [self layoutIfNeeded];
}

-(void)resetAnimation{
    _blockOneFull = YES;
    
    _blockOne.transform = CGAffineTransformMakeScale(0.01, 0.01);
    _blockTwo.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
#warning DEBIT: Conflito entre as animações de resetar os blocos e o scroll do tableview voltando
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _isRefreshAnimating = NO;
    });
}

-(void)loadingAnimation{
    _isRefreshAnimating = YES;
    [self setNeedsLayout];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        
        _blockOne.transform = CGAffineTransformMakeScale(_scaleOne, _scaleOne);
        _blockTwo.transform = CGAffineTransformMakeScale(_scaleTwo, _scaleTwo);
        
        if (_blockOneFull) {
            _scaleOne += STEP_DEFAULT;
            _scaleTwo -= STEP_DEFAULT;
        }else{
            _scaleOne -= STEP_DEFAULT;
            _scaleTwo += STEP_DEFAULT;
        }
        
        if (_scaleOne > 1) {
            _scaleOne = 1;
        }else if (_scaleOne <= 0){
            _scaleOne = 0.2;
        }
        if(_scaleTwo > 1){
            _scaleTwo = 1;
        }else if(_scaleTwo <= 0){
            _scaleTwo = 0.2;
        }
        _blockOneFull = (_scaleOne == 1.0 || _scaleTwo == 1.0) ? !_blockOneFull : _blockOneFull;
        
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        BOOL r = _refreshingCheck();
        if (r) {
            [self loadingAnimation];
        }else{
            [self resetAnimation];
        }
    }];
}

-(void)pullAnimation:(CGFloat)percent{
    
    if (!_isRefreshAnimating && percent <= 1) {
       
        _blockOne.transform = CGAffineTransformMakeScale(percent, percent);
        _blockTwo.transform = CGAffineTransformMakeScale(percent, percent);
        _scaleOne = percent;
        _scaleTwo = percent;
        NSLog(@"%.02f", percent);
    }
    
}


@end
