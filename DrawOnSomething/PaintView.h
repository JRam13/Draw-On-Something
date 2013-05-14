//
//  PaintView.h
//  Paint
//
//  Created by T. Andrew Binkowski on 4/30/13.
//  Copyright (c) 2013 T. Andrew Binkowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaintView;

////////////////////////////////////////////////////////////////////////////////
@protocol PaintViewDelegate <NSObject>
@required
- (void)paintView:(PaintView*)paintView finishedTrackingPath:(CGPathRef)path inRect:(CGRect)painted;
@end

////////////////////////////////////////////////////////////////////////////////
@interface PaintView : UIView
@property (nonatomic, assign) id <PaintViewDelegate> delegate;
@property (strong, nonatomic) UIColor *lineColor;

- (void)erase;
@end
