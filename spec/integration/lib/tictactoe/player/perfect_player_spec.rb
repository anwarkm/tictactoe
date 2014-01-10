# Encoding: utf-8

require 'spec_helper'
require 'tictactoe/board'
require 'tictactoe/player/perfect_player'

def get_player(piece)
  Tictactoe::Player::PerfectPlayer.new(piece)
end

describe Tictactoe::Player::PerfectPlayer do

  it 'should reject a game state where it is not the turn taking player' do
    board = test_board '_oxooxxxo', 3, 'x', 'o'
    player = get_player 'o'
    expect do
      player.take_turn(board)
    end.to raise_error ArgumentError, 'It is not this player\'s turn.'
  end

  it 'should pick a good opening move if the board is blank' do
    board = test_board('_________')
    player = get_player 'x'
    new_board = player.take_turn(board)
    new_board.board.flatten.should include 'x'
    new_board.player_piece.should eq 'o'
  end

  it 'should simply fill in the last space if there is only one blank' do
    board = test_board '_oxooxxxo', 3, 'x', 'o'
    player = get_player 'x'
    new_board = player.take_turn(board)
    new_board.draw?.should be_true
  end

  it 'should pick the winning move of a nearly complete game for x' do
    board = test_board 'xo_xx__oo', 3, 'x', 'o'
    player = get_player 'x'
    new_board = player.take_turn(board)
    new_board.available_moves.count.should eq 2
    new_board.won?('x').should be_true
  end

  it 'should pick the winning move of a nearly complete game for o' do
    board = test_board 'xoxxx__oo', 3, 'o', 'x'
    player = get_player 'o'
    new_board = player.take_turn(board)
    new_board.won?('o').should be_true
  end

  it 'should pick the winning move from a more incomplete game' do
    board = test_board('x_x_o__o_', 3, 'x', 'o')
    player = get_player 'x'
    new_board = player.take_turn(board)
    new_board.won?('x').should be_true
  end

  it 'should pick the next move from a more incomplete game', profile: true do
    board = test_board('o________', 3, 'x', 'o')
    player = get_player 'x'
    new_board = player.take_turn(board)
    new_board.available_moves.length.should eq 7
    new_board.over?.should be_false
  end

  it 'should clearly block a move' do
    board = test_board('____x_x_o', 3, 'o', 'x')
    player = get_player 'o'
    new_board = player.take_turn(board)
    new_board.available_moves.length.should eq 5
    new_board.over?.should be_false
    new_board.available_moves.should_not include [0, 2]
  end

  it 'should clearly block a move 2' do
    board = test_board('o____x__x', 3, 'o', 'x')
    player = get_player 'o'
    new_board = player.take_turn(board)
    new_board.available_moves.length.should eq 5
    new_board.over?.should be_false
    new_board.available_moves.should_not include [0, 2]
  end

  it 'should clearly block a move 3' do
    board = test_board('x_o_xx__o', 3, 'o', 'x')
    player = get_player 'o'
    new_board = player.take_turn(board)
    new_board.available_moves.should_not include [1, 0]
  end

  it 'should work with an alternative state' do
    board = test_board('__zj', 2, 'z', 'j')
    player = get_player 'z'
    new_board = player.take_turn(board)
    new_board.available_moves.should_not include [0, 0]
  end

  it 'should clearly block a move 3' do
    board = test_board('_x___xoox', 3, 'o', 'x')
    player = get_player 'o'
    new_board = player.take_turn(board)
    new_board.over?.should be_false
    new_board.available_moves.should_not include [0, 2]
  end

  it 'should always draw when playing itself' do
    players = { 'x' => Tictactoe::Player::PerfectPlayer.new('x'), 'o' => Tictactoe::Player::PerfectPlayer.new('o') }
    results = []
    (1..10).each do
      board = test_board('_________')
      while board.over? == false
        board = players[board.player_piece].take_turn(board)
      end
      results.push board.draw?
    end
    results.should_not include false
  end
end
