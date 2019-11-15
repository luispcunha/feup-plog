:- ensure_loaded('game_logic.pl').
:- ensure_loaded('game_model.pl').
:- ensure_loaded('graph.pl').
:- ensure_loaded('gameover.pl').
:- ensure_loaded('display.pl').

% init_game_state([[
%              [0, 0, 0, 0, 0, 0, 2, 0],
%              [0, 0, 0, 0, 2, 2, 0, 2],
%              [1, 1, 1, 2, 0, 1, 2, 0],
%              [0, 0, 0, 0, 0, 0, 0, 0],
%              [0, 0, 0, 0, 0, 0, 0, 0],
%              [0, 0, 0, 0, 0, 0, 0, 0],
%              [0, 0, 0, 0, 0, 0, 0, 0],
%              [0, 0, 0, 0, 0, 0, 0, 0]
%             ],
%             [
%              [0, 1, 1, 1, 1, 1, 1, 1, 0],
%              [2, 0, 0, 0, 0, 0, 2, 2, 2],
%              [2, 0, 0, 0, 2, 2, 2, 2, 2],
%              [2, 0, 0, 0, 0, 0, 0, 0, 2],
%              [2, 0, 0, 0, 0, 0, 0, 0, 2],
%              [2, 0, 0, 0, 0, 0, 0, 0, 2],
%              [2, 0, 0, 0, 0, 0, 0, 0, 2],
%              [2, 0, 0, 0, 0, 0, 0, 0, 2],
%              [0, 1, 1, 1, 1, 1, 1, 1, 0]
%             ],
%             8,
%             8,
%             1,
%             1,
%             1,
%             1-0 ]).


random_move(GameState, Move) :-
    valid_moves(GameState, ListOfMoves),
    random_member(Move, ListOfMoves).


% Level-2 Bot

greedy_move(GameState, BestMove) :-
    valid_moves(GameState,ListOfMoves),
    findall(Value-Move, (member(Move, ListOfMoves),move(Move, GameState, NewGameState), value(NewGameState, Value)), Result),
    keysort(Result,SortedResultAsc),
    reverse(SortedResultAsc,SortedResultDsc),
    % print(SortedResultDsc),
    nth0(0,SortedResultDsc,_-BestMove).

value(GameState, Value) :-

    % print(GameState),
    GameState = [OctagonBoard,SquareBoard, Height, Width|_],
    get_game_previous_player(GameState,PrevPlayer),
    orient_board(OctagonBoard, SquareBoard,PrevPlayer,OrientedOctagonBoard,OrientedSquareBoard),
    build_graph([OrientedOctagonBoard, OrientedSquareBoard, Height, Width], PrevPlayer, Graph),!,
    get_highest_sub_board_value(OrientedOctagonBoard,Width,Height,PrevPlayer,Graph,Value).

get_highest_sub_board_value(OctagonBoard,Width,Height,Player,Graph,Value) :- !,get_highest_sub_board_value_iter(OctagonBoard,Width,Height,Player,Graph,Height,Value).

get_highest_sub_board_value_iter(_,_,_,_,_,0,0) :-!.

get_highest_sub_board_value_iter(OctagonBoard,Width,Height,Player,Graph,CurrentBoardSize,Value) :-

    AlternativeCount is Height - CurrentBoardSize + 1,

    % write('-sub_board_iter1 - Number of alternatives: '), write(AlternativeCount), nl,
    \+check_sub_boards(OctagonBoard,Width,Height,Player,Graph,AlternativeCount,AlternativeCount),

    NewSize is CurrentBoardSize - 1,
    get_highest_sub_board_value_iter(OctagonBoard,Width,Height,Player,Graph,NewSize,Value).

get_highest_sub_board_value_iter(OctagonBoard,Width,Height,Player,Graph,CurrentBoardSize,Value) :-

    AlternativeCount is Height - CurrentBoardSize + 1,

    % write('-sub_board_iter2 - Number of alternatives: '), write(AlternativeCount), nl,
    check_sub_boards(OctagonBoard,Width,Height,Player,Graph,AlternativeCount,AlternativeCount),

    Value is CurrentBoardSize.




check_sub_boards(_,_,_,_,_,_,0) :- !,fail.


check_sub_boards(OctagonBoard,Width,Height,Player,Graph,AlternativeCount,CurrentAlternative) :-
    LowBar is CurrentAlternative - 1,
    HighBar is LowBar + Height - AlternativeCount,
    % write('-- board_iter1 - Number of alternatives: '), write(AlternativeCount), write(' Lowbar: '),write(LowBar), write(' Highbar: '),write(HighBar),nl,
    
    \+get_valid_starters(OctagonBoard,Player,LowBar,Width,_),

    CurrentAlternative1 is CurrentAlternative - 1, 
    check_sub_boards(OctagonBoard,Width,Height,Player,Graph,AlternativeCount,CurrentAlternative1).


check_sub_boards(OctagonBoard,Width,Height,Player,Graph,AlternativeCount,CurrentAlternative) :-
    LowBar is CurrentAlternative - 1,
    HighBar is LowBar + Height - AlternativeCount,
    % write('-- board_iter2 - Number of alternatives: '), write(AlternativeCount), write(' Lowbar: '),write(LowBar), write(' Highbar: '),write(HighBar),nl,
    
    get_valid_starters(OctagonBoard,Player,LowBar,Width,Starters),

    gen_row_ids(Width,HighBar,IDList),
    % print(Starters),nl,
    % print(IDList),nl,
    % print(Graph),nl,
    
    \+reachable_from_list(Graph,Starters,IDList),
    % write('not reachable'),nl,
    CurrentAlternative1 is CurrentAlternative - 1, 
    check_sub_boards(OctagonBoard,Width,Height,Player,Graph,AlternativeCount,CurrentAlternative1).

check_sub_boards(OctagonBoard,Width,Height,Player,Graph,AlternativeCount,CurrentAlternative) :-
    LowBar is CurrentAlternative - 1,
    HighBar is LowBar + Height - AlternativeCount,
    % write('-- board_iter3 - Number of alternatives: '), write(AlternativeCount), write(' Lowbar: '),write(LowBar), write(' Highbar: '),write(HighBar),nl,
    
    get_valid_starters(OctagonBoard,Player,LowBar,Width,Starters),
    gen_row_ids(Width,HighBar,IDList),
    
    reachable_from_list(Graph,Starters,IDList).