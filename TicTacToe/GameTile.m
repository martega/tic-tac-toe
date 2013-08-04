//
//  GameTile.m
//  TicTacToe
//
//  Created by Martin Ortega on 8/2/13.
//  Copyright (c) 2013 Martin Ortega. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GameTile.h"

////////////////////////////////////////////////////////////////////////////

#pragma mark - Implementation

@implementation GameTile

@synthesize location = _location;

//--------------------------------------------------------------------------

#pragma mark - Designated Initializer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        // shadow
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.3;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 15;
        
        // gradient
        UIColor *light = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        UIColor *dark = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.layer.frame;
        gradient.colors = @[(id)light.CGColor, (id)dark.CGColor];
        [self.layer addSublayer:gradient];
        
        // rounded corners
        self.layer.cornerRadius = 15;
        gradient.cornerRadius = 15;
    }
    return self;
}

//--------------------------------------------------------------------------

#pragma mark - Image Setter

- (void)setTileImage:(UIImage *)image
{
    UIImageView *tileImageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, 15, 15)];
    tileImageView.image = image;
    [self addSubview:tileImageView];
}

@end
