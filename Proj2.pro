%Project 2, COMP30020, Constantinos Kavadias, Student ID: 664790
%Unviersity of Melbourne, ckavadias@student.unimelb.edu.au, September 2017

%The following is verification/construction program to solve the problem of
%a "Puzzle". A Puzzle is valid given the the elements in each row/column are 
%unique from the other elements in that row/columm, the top left to bottom
%right diagonal contains the same digit in all cells, the rows/columns are the
%sum or product of the header(initial) element and all elements are >1 or <9.
:-ensure_loaded(library(clpfd)).
use_module(library(lists)).

puzzle_solution(Puzzle):- diagonal(Puzzle),rows(Puzzle),
                          transpose(Puzzle, T_Puzzle),rows(T_Puzzle).

rows([_| Rs]):- valid_rows(Rs).

valid_rows([]).
valid_rows([[H|R] | Rs]):- valid_el(R),(sum_list(R, H); product_list(H, R)),
                           valid_rows(Rs).

product_list(H, R):- make_product(R, 1, H).
make_product([], H, H).
make_product([E | Es], A, H):- (Product is E*A), make_product(Es, Product, H).

valid_el([]).                           
valid_el([E | Es]):- (1 =< E),(E =< 9),(\+member(E, Es)).valid(Es).

diagonal([_, _]).
diagonal([ _, [_, X | _], [_, _, X| _]]).
diagonal([ _, [_, X | _], [_, _, X| _], [_, _, _, X| _]]).