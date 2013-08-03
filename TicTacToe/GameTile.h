//
//  GameTile.h
//  TicTacToe
//
//  Created by Martin Ortega on 8/2/13.
//  Copyright (c) 2013 Martin Ortega. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameTile : UIButton

@property (nonatomic, strong) NSIndexPath *location;

- (void)setTileImage:(UIImage *)image;

@end
