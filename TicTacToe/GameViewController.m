//
//  GameViewController.m
//  TicTacToe
//
//  Created by Martin Ortega on 8/1/13.
//  Copyright (c) 2013 Martin Ortega. All rights reserved.
//

#import "GameViewController.h"
#import "GameTile.h"
#import "Settings.h"

////////////////////////////////////////////////////////////////////////////

#pragma mark - Private Interface

@interface GameViewController () {
    GameTile* gameTiles[3][3];
}

@property (nonatomic, strong) Game *game;

@end

////////////////////////////////////////////////////////////////////////////

#pragma mark - Implementation

@implementation GameViewController

//--------------------------------------------------------------------------

#pragma mark - Game

- (void)setupGameBoard:(void (^)(void))onCompletion
{
    float delay = 0;
    float delayDelta = 0.06;
    float animationDuration = 0.3;
    
    CGFloat tileSize = (self.view.frame.size.width - 4*kGameTilePadding)/3;
        
    for (int row = 0; row < 3; row++) {
        for (int col = 2; col >= 0; col--) {
            // tile's final position
            CGFloat x = self.view.center.x + (col - 1)*(tileSize + kGameTilePadding);
            CGFloat y = self.view.center.y + (row - 1)*(tileSize + kGameTilePadding);
            
            // create the tile
            CGRect tileFrame = CGRectMake(0, 0, tileSize, tileSize);
            GameTile *tile = [[GameTile alloc] initWithFrame:tileFrame];
            gameTiles[row][col] = tile;
            tile.location = [NSIndexPath indexPathForRow:row inSection:col];
            [tile addTarget:self action:@selector(tappedGameTile:) forControlEvents:UIControlEventTouchUpInside];
            
            // animate it's movement from offscreen to it's final position
            tile.center = CGPointMake(x - 2*self.view.center.x, y);

            
            [UIView animateWithDuration:animationDuration
                                  delay:delay
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 tile.center = CGPointMake(x, y);
                             }
                             completion:nil];
            
            [self.view addSubview:tile];
            
            delay += delayDelta;
        }
    }

    double delayInSeconds = delay + animationDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), onCompletion);
}

//--------------------------------------------------------------------------

- (void)clearGameBoard:(void (^)(void))onCompletion
{
    float delay = 0;
    float delayDelta = 0.06;
    float animationDuration = 0.3;
        
    for (int row = 0; row < 3; row++) {
        for (int col = 2; col >= 0; col--) {
            // get the tile
            GameTile *tile = gameTiles[row][col];
            
            // animate it's movement offscreen            
            [UIView animateWithDuration:animationDuration
                                  delay:delay
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 tile.center = CGPointMake(tile.center.x + 2*self.view.center.x, tile.center.y);
                             }
                             completion:^(BOOL finished) {
                                 [tile removeFromSuperview];
                             }];
                        
            delay += delayDelta;
        }
    }
    
    double delayInSeconds = delay + animationDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), onCompletion);
}

- (void)startNewGame
{
    [self clearGameBoard:^{
        [self setupGameBoard:^{
            [self.game startNewGame];
        }];
    }];
}

//--------------------------------------------------------------------------

#pragma mark - User Interface Actions


- (IBAction)tappedGameTile:(GameTile *)tile
{
    [self.game makeMoveAtPosition:tile.location];
}

- (IBAction)menuButtonPressed:(id)sender {
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@""
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"New Game", nil];
    
    [menu showInView:self.view];
}

//--------------------------------------------------------------------------

#pragma mark - Game Delegate Methods

- (void)game:(Game *)game player:(TicTacToePlayer)player didMoveToPosition:(NSIndexPath *)position
{
    // get the tile
    int row = position.row;
    int col = position.section;
    GameTile *tile = gameTiles[row][col];
    
    // flip the tile
    [UIView beginAnimations:@"tile flip" context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:tile cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    
    // change the tile symbol
    switch (player) {
        case PlayerX:
            [tile setTileImage:[UIImage imageNamed:@"cross"]];
            break;
            
        case PlayerO:
            [tile setTileImage:[UIImage imageNamed:@"circle"]];
            break;
            
        default:
            break;
    }
    
    [UIView commitAnimations];
}

- (void)game:(Game *)game player:(TicTacToePlayer)player didMakeIllegalMoveAtPosition:(NSIndexPath *)position
{
    // get the tile
    int row = position.row;
    int col = position.section;
    GameTile *tile = gameTiles[row][col];
    
    // shake the tile
    CGFloat translationAmount = 2.0;
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -translationAmount, -translationAmount);
    CGAffineTransform translateRight = CGAffineTransformTranslate(CGAffineTransformIdentity, translationAmount, translationAmount);

    tile.transform = translateLeft;
    
    [UIView animateWithDuration:0.06
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState |
                                UIViewAnimationOptionAutoreverse           |
                                UIViewAnimationOptionRepeat
                     animations:^{
                         [UIView setAnimationRepeatCount:10];
                         tile.transform = translateRight;
                     }
                     completion:^(BOOL finished) {
                         tile.transform = CGAffineTransformIdentity;
                     }];
    
}

- (void)game:(Game *)game didFinishWithWinningPlayer:(TicTacToePlayer)player
{
    NSString *message;
    
    switch (player) {
        case PlayerX:
            message = @"Player X wins!";
            break;
        
        case PlayerO:
            message = @"Player O wins!";
            break;
            
        case NoPlayer:
            message = @"Tie game!";
            
        default:
            break;
    }
    
    UIAlertView *gameOverMessage = [[UIAlertView alloc] initWithTitle:message
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
    
    [gameOverMessage show];
}

//--------------------------------------------------------------------------

#pragma mark - UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self startNewGame];
            break;
            
        default:
            break;
    }
}

//--------------------------------------------------------------------------

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupGameBoard:^{
        self.game = [[Game alloc] init];
        self.game.delegate = self;
    }];
}

@end
