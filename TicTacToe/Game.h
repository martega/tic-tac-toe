//
//  Game.h
//  TicTacToe
//
//  Created by Martin Ortega on 8/1/13.
//  Copyright (c) 2013 Martin Ortega. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Game;

////////////////////////////////////////////////////////////////////////////

#pragma mark - Player Types

typedef enum {
    PlayerX,
    PlayerO,
    NoPlayer
} TicTacToePlayer;

////////////////////////////////////////////////////////////////////////////

#pragma mark - Game Protocol

@protocol GameProtocol <NSObject>

@optional

- (void)game:(Game *)game player:(TicTacToePlayer)player didMoveToPosition:(NSIndexPath *)position;
- (void)game:(Game *)game player:(TicTacToePlayer)player didMakeIllegalMoveAtPosition:(NSIndexPath *)position;
- (void)game:(Game *)game didFinishWithWinningPlayer:(TicTacToePlayer)player andWinningMoves:(NSArray *)winningMoves;

@end

////////////////////////////////////////////////////////////////////////////

#pragma mark - Game Interface

@interface Game : NSObject

@property (nonatomic, weak) id<GameProtocol> delegate;
@property (nonatomic, readonly) TicTacToePlayer playerTurn;
@property (nonatomic, readonly) BOOL isOver;

- (void)startNewGame;
- (void)makeMoveAtPosition:(NSIndexPath *)position;

@end
