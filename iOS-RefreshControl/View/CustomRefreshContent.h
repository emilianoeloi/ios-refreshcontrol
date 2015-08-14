//
//  CustomRefreshContent.h
//  iOS-RefreshControl
//
//  Created by Emiliano Barbosa on 8/13/15.
//  Copyright (c) 2015 Bocamuchas. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CORNER_RADIUS_DEFAULT 5.0f
#define ANIMATION_DURATION 1.2f
#define STEP_DEFAULT 1.0f
#define REFRESH_DELAY 3.0f

typedef BOOL (^LoadingAnimationBlock)();
typedef void (^KeyframeAnimationBlock)();

@interface CustomRefreshContent : UIView
-(instancetype) initWithFrame:(CGRect)frame refreshingCheck:(LoadingAnimationBlock)refreshingCheck;
-(void) loadingAnimation;
-(void) pullAnimation:(CGFloat)percent;
-(void)start;

@end
