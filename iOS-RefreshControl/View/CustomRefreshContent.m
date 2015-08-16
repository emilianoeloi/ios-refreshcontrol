//
//  CustomRefreshContent.m
//  iOS-RefreshControl
//
//  Created by Emiliano Barbosa on 8/13/15.
//  Copyright (c) 2015 Bocamuchas. All rights reserved.
//

#import "CustomRefreshContent.h"

@interface CustomRefreshContent()

@property (weak, nonatomic) IBOutlet UIView *viewOne;
@property (weak, nonatomic) IBOutlet UIView *viewTwo;
@property (weak, nonatomic) IBOutlet UIView *viewThree;
@property (weak, nonatomic) IBOutlet UIView *viewFour;
@property (nonatomic, strong) LoadingAnimationBlock refreshingCheck;


@property (nonatomic) BOOL isRefreshAnimating;

@property (nonatomic) CGFloat scale;

@property (nonatomic) CGFloat scaleOne;
@property (nonatomic) CGFloat scaleTwo;
@property (nonatomic) CGFloat scaleThree;
@property (nonatomic) CGFloat scaleFour;

@property (nonatomic, strong) NSArray *blockArray;
@property (nonatomic) int currentAnimationBlockIndex;

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
        
        [_viewOne.layer setCornerRadius:CORNER_RADIUS_DEFAULT];
        [_viewTwo.layer setCornerRadius:CORNER_RADIUS_DEFAULT];
        [_viewThree.layer setCornerRadius:CORNER_RADIUS_DEFAULT];
        [_viewFour.layer setCornerRadius:CORNER_RADIUS_DEFAULT];
        
        [self setup];
        [self resetAnimation];
        
    }
    return self;
}

-(void)setup{
    _scale = 0.0f;
    _scaleOne = 0.0f;
    _scaleTwo = 0.0f;
    _scaleThree = 0.0f;
    _scaleFour = 0.0f;
}

-(void)prepareForAnimation{
}

-(void)resetAnimation{
    
    [_viewOne setTransform:CGAffineTransformMakeScale(0.25, 0.25)];
    [_viewTwo setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
    [_viewThree setTransform:CGAffineTransformMakeScale(0.75, 0.75)];
    [_viewFour setTransform:CGAffineTransformMakeScale(0.1, 1.0)];
    
#warning DEBIT: Conflito entre as animações de resetar os blocos e o scroll do tableview voltando
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _isRefreshAnimating = NO;
    });
}

-(void)start{
    [self resetAnimation];
    [self loadingAnimation];
}

-(void)loadingAnimation{
    _isRefreshAnimating = YES;
    
    void (^blockComplete)(BOOL) = ^(BOOL finished){
        if (_refreshingCheck() == YES) {
            [self loadingAnimation];
        }else{
            [self resetAnimation];
        }
    };
    
    [UIView animateKeyframesWithDuration:ANIMATION_DURATION delay:0 options: UIViewAnimationOptionCurveLinear animations:^{
        
        /// One
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.50 animations:^{
            [_viewOne setTransform:CGAffineTransformMakeScale(0.0, 0.0)];
        }];
        [UIView addKeyframeWithRelativeStartTime:0.50 relativeDuration:0.50 animations:^{
            [_viewOne setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        }];
        
        /// Two
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.25 animations:^{
            [_viewTwo setTransform:CGAffineTransformMakeScale(0.0, 0.0)];
        }];
        [UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.50 animations:^{
            [_viewTwo setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        }];
        [UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
            [_viewTwo setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
        }];
        
        /// Three
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.50 animations:^{
            [_viewThree setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        }];
        [UIView addKeyframeWithRelativeStartTime:0.50 relativeDuration:0.50 animations:^{
            [_viewThree setTransform:CGAffineTransformMakeScale(0.0, 0.0)];
        }];
        
        /// Four
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.25 animations:^{
            [_viewFour setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        }];
        [UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.50 animations:^{
            [_viewFour setTransform:CGAffineTransformMakeScale(0.0, 0.0)];
        }];
        [UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
            [_viewFour setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
        }];

    } completion:blockComplete];
    
}

-(CGFloat)scaleWithStartScale:(CGFloat)startScale scrollPercent:(CGFloat)scrollPercent max:(CGFloat)max {
    CGFloat scale = 1.0 * scrollPercent / max;
    CGFloat newScale = startScale * scale / 1.0;
    newScale = (newScale > startScale) ? startScale : newScale;
    return newScale;
}

-(void)pullAnimation:(CGFloat)percent{
    
    if (!_isRefreshAnimating && percent <= 1) {
       
#warning TODO: Fazer animação do pull indo do zero até a posição inicial do refresh animation
        
        _scaleOne = [self scaleWithStartScale:0.25 scrollPercent:percent max:0.25];
        _scaleTwo = [self scaleWithStartScale:0.50 scrollPercent:percent max:0.50];
        _scaleThree = [self scaleWithStartScale:0.75 scrollPercent:percent max:0.75];
        _scaleFour = [self scaleWithStartScale:1.0 scrollPercent:percent max:1.00];
        
        _viewOne.transform = CGAffineTransformMakeScale(_scaleOne, _scaleOne);
        _viewTwo.transform = CGAffineTransformMakeScale(_scaleTwo, _scaleTwo);
        _viewThree.transform = CGAffineTransformMakeScale(_scaleThree, _scaleThree);
        _viewFour.transform = CGAffineTransformMakeScale(_scaleFour, _scaleFour);
        NSLog(@"%.02f", percent);
    }
    
}


@end
