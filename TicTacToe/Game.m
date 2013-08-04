//
//  Game.m
//  TicTacToe
//
//  Created by Martin Ortega on 8/1/13.
//  Copyright (c) 2013 Martin Ortega. All rights reserved.
//

#import "Game.h"

////////////////////////////////////////////////////////////////////////////

#pragma mark - Private Interface

@interface Game () {
    TicTacToePlayer gameBoard[3][3];
}

@property (nonatomic, readwrite) TicTacToePlayer playerTurn;
@property (nonatomic, readwrite) BOOL isOver;
@property (nonatomic, readwrite) int numMoves;

- (NSArray *)findWinningMoves;

@end

////////////////////////////////////////////////////////////////////////////

#pragma mark - Implementation

@implementation Game

@synthesize delegate = _delegate;
@synthesize playerTurn = _playerTurn;
@synthesize isOver = _isOver;
@synthesize numMoves = _numMoves;

//--------------------------------------------------------------------------

#pragma mark - Designated Initializer

- (id)init
{
    self = [super init];
    if (self) {
        [self startNewGame];
    }
    return self;
}

//--------------------------------------------------------------------------

#pragma mark - Instance Methods

- (void)startNewGame
{
    for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
            gameBoard[row][col] = NoPlayer;
        }
    }
    
    self.numMoves = 0;
    self.isOver = NO;
}

//--------------------------------------------------------------------------

- (void)makeMoveAtPosition:(NSIndexPath *)position
{
    int row = position.row;
    int col = position.section;
    
    // make sure move is legal
    if (gameBoard[row][col] != NoPlayer || self.isOver) {
        if ([self.delegate respondsToSelector:@selector(game:player:didMakeIllegalMoveAtPosition:)]) {
            [self.delegate game:self player:self.playerTurn didMakeIllegalMoveAtPosition:position];
        }
        return;
    }
    
    // make move
    gameBoard[row][col] = self.playerTurn;
    self.numMoves += 1;
    if ([self.delegate respondsToSelector:@selector(game:player:didMoveToPosition:)]) {
        [self.delegate game:self player:self.playerTurn didMoveToPosition:position];
    }
    
    // handle the end game
    NSArray *winningMoves = [self findWinningMoves];
    BOOL currentPlayerWon = winningMoves.count != 0;
    if (currentPlayerWon) {
        self.isOver = YES;
        [self.delegate game:self didFinishWithWinningPlayer:self.playerTurn andWinningMoves:winningMoves];
    }
    else if (self.numMoves == 9) {
        self.isOver = YES;
        [self.delegate game:self didFinishWithWinningPlayer:NoPlayer andWinningMoves:winningMoves];
    }
    
    // get ready for the next turn
    self.playerTurn = self.playerTurn == PlayerX ? PlayerO : PlayerX;
}

//--------------------------------------------------------------------------

- (NSArray *)findWinningMoves
{    
    // check for a win in all rows and columns
    for (int i = 0; i < 3; i++) {
        BOOL winningRow = YES;
        BOOL winningCol = YES;
        for (int j = 0; j < 3; j++) {
            if (gameBoard[i][j] != self.playerTurn) {
                winningRow = NO;
            }
            
            if (gameBoard[j][i] != self.playerTurn) {
                winningCol = NO;
            }
        }
        
        if (winningRow) {
            return @[[NSIndexPath indexPathForRow:i inSection:0],
                     [NSIndexPath indexPathForRow:i inSection:1],
                     [NSIndexPath indexPathForRow:i inSection:2]];
        }
        
        if (winningCol) {
            return @[[NSIndexPath indexPathForRow:0 inSection:i],
                     [NSIndexPath indexPathForRow:1 inSection:i],
                     [NSIndexPath indexPathForRow:2 inSection:i]];
        }
 
    }
    
    // check for a diagonal win
    if (gameBoard[0][0] == self.playerTurn &&
        gameBoard[1][1] == self.playerTurn &&
        gameBoard[2][2] == self.playerTurn)
    {
        return @[[NSIndexPath indexPathForRow:0 inSection:0],
                 [NSIndexPath indexPathForRow:1 inSection:1],
                 [NSIndexPath indexPathForRow:2 inSection:2]];
    }

    if (gameBoard[0][2] == self.playerTurn &&
        gameBoard[1][1] == self.playerTurn &&
        gameBoard[2][0] == self.playerTurn)
    {
        return @[[NSIndexPath indexPathForRow:0 inSection:2],
                 [NSIndexPath indexPathForRow:1 inSection:1],
                 [NSIndexPath indexPathForRow:2 inSection:0]];
    }

    // nobody won :(
    return @[ ];
}

@end
