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
@property (nonatomic) CGFloat gameTileSize;

@end

////////////////////////////////////////////////////////////////////////////

#pragma mark - Implementation

@implementation GameViewController

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

//--------------------------------------------------------------------------

#pragma mark - Displaying the Gameboard

- (void)setupGameBoard:(void (^)(void))onCompletion
{
    float delay = 0;
    float delayDelta = 0.06;
    float animationDuration = 0.3;
        
    for (int row = 0; row < 3; row++) {
        for (int col = 2; col >= 0; col--) {
            GameTile *tile = [self createGameTileForRow:row column:col];
            
            CGFloat x = self.view.center.x + (col - 1)*(self.gameTileSize + kGameTilePadding);
            CGFloat y = self.view.center.y + (row - 1)*(self.gameTileSize + kGameTilePadding);
            
            CGPoint start = CGPointMake(x - 2*self.view.center.x, y);
            CGPoint end = CGPointMake(x, y);
            
            [self slideGameTileOnScreen:tile start:start end:end duration:animationDuration delay:delay];
                        
            delay += delayDelta;
        }
    }

    // invoke the callback after the last tile has slid into place
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
            GameTile *tile = [self getGameTileAtRow:row column:col];
            [self slideGameTileOffScreen:tile duration:animationDuration delay:delay];                        
            delay += delayDelta;
        }
    }
    
    // invoke the callback after the last tile is offscreen
    double delayInSeconds = delay + animationDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), onCompletion);
}

//--------------------------------------------------------------------------

- (void)startNewGame
{
    [self clearGameBoard:^{
        [self setupGameBoard:^{
            [self.game startNewGame];
        }];
    }];
}

//--------------------------------------------------------------------------

- (void)highlightWinningMoves:(NSArray *)winningMoves onCompletion:(void (^)(void))onCompletion
{
    // I need still need to figure out how to do this.
    [onCompletion invoke];
}

//--------------------------------------------------------------------------

- (void)displayGameOverMessageForPlayer:(TicTacToePlayer)winningPlayer
{
    NSString *message;
    
    switch (winningPlayer) {
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
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [gameOverMessage show];
    });
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
    GameTile *tile = [self getGameTileAtPosition:position];
    [self flipGameTile:tile toRevealSymbolForPlayer:player];
}

//--------------------------------------------------------------------------

- (void)game:(Game *)game player:(TicTacToePlayer)player didMakeIllegalMoveAtPosition:(NSIndexPath *)position
{
    GameTile *tile = [self getGameTileAtPosition:position];    
    [self shakeTile:tile];
}

//--------------------------------------------------------------------------

- (void)game:(Game *)game didFinishWithWinningPlayer:(TicTacToePlayer)winningPlayer andWinningMoves:(NSMutableArray *)winningMoves
{
    __block TicTacToePlayer player = winningPlayer;
    [self highlightWinningMoves:winningMoves onCompletion:^{
        [self displayGameOverMessageForPlayer:player];
    }];
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

#pragma mark - Utility Methods

- (GameTile *)getGameTileAtPosition:(NSIndexPath *)position
{
    int row = position.row;
    int col = position.section;
    return gameTiles[row][col];
}

//--------------------------------------------------------------------------

- (GameTile *)getGameTileAtRow:(NSUInteger)row column:(NSUInteger)col
{
    return gameTiles[row][col];
}

//--------------------------------------------------------------------------

- (void)shakeTile:(GameTile *)tile
{
    CGFloat shiftAmount = 2.0;
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -shiftAmount, -shiftAmount);
    CGAffineTransform translateRight = CGAffineTransformTranslate(CGAffineTransformIdentity, shiftAmount, shiftAmount);
    
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

//--------------------------------------------------------------------------

- (GameTile *)createGameTileForRow:(NSUInteger)row column:(NSUInteger)col
{
    CGRect tileFrame = CGRectMake(0, 0, self.gameTileSize, self.gameTileSize);
    GameTile *tile = [[GameTile alloc] initWithFrame:tileFrame];
    gameTiles[row][col] = tile;
    tile.location = [NSIndexPath indexPathForRow:row inSection:col];
    [self.view addSubview:tile];
    [tile addTarget:self action:@selector(tappedGameTile:) forControlEvents:UIControlEventTouchUpInside];
    
    return tile;
}

//--------------------------------------------------------------------------

- (void)slideGameTileOnScreen:(GameTile *)tile
                        start:(CGPoint)start
                          end:(CGPoint)end
                     duration:(NSTimeInterval)duration
                        delay:(NSTimeInterval)delay
{
    tile.center = start;

    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         tile.center = end;
                     }
                     completion:nil];
}

//--------------------------------------------------------------------------

- (void)slideGameTileOffScreen:(GameTile *)tile duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         tile.center = CGPointMake(tile.center.x + 2*self.view.center.x, tile.center.y);
                     }
                     completion:^(BOOL finished) {
                         [tile removeFromSuperview];
                     }];
}

//--------------------------------------------------------------------------

- (void)flipGameTile:(GameTile *)tile toRevealSymbolForPlayer:(TicTacToePlayer)player
{
    [UIView beginAnimations:@"tile flip" context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:tile cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    
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

//--------------------------------------------------------------------------

- (CGFloat)gameTileSize
{
    return (self.view.frame.size.width - 4*kGameTilePadding)/3;
}

@end
