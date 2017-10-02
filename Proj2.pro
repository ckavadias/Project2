%Project 2, COMP30020, Constantinos Kavadias, Student ID: 664790
%Unviersity of Melbourne, ckavadias@student.unimelb.edu.au, September 2017

%The following is verification/construction program to solve the problem of
%a "Puzzle". A Puzzle is valid given the the elements in each row/column are 
%unique from the other elements in that row/columm, the top left to bottom
%right diagonal contains the same digit in all cells, the rows/columns are the
%sum or product of the header(initial) element and all elements are >=1 or <=9.
:-ensure_loaded(library(clpfd)).
use_module(library(lists)).

puzzle_solution(Puzzle):- link_diagonal(Puzzle),
                          make_puzzle(Puzzle).

%bind diagonal's to eachother
link_diagonal([[_, H], [H, H]]).
link_diagonal([_, [_, X, _], [_, _, X]]).
link_diagonal([_, [_, X | _], [_, _, X, _], [_, _, _, X]]).
link_diagonal([_, [_, X | _], [_, _, X| _], [_, _, _, X, _], [_, _, _, _,X]]).

make_puzzle([H|Puzzle]):- make_rows(Puzzle, [H|Puzzle]), 
                          transpose([H|Puzzle],[_|TPuz]), check_sp(TPuz).

                          
%check that is all rows are true sum and product
check_sp([]).
check_sp([[H | R] | Rs]):- (sum_list(R, H);product_list(R, H)), check_sp(Rs).

%determine row with minimum solutions
min_sols([], _, Min, Min, MinSols, MinSols, _).
min_sols([R | Rs], Len, CMin, Min, CSols, MinSols, Puzzle):- 
                                  (bagof(R,is_valid_row(R, Puzzle),Sols),
                                  length(Sols, L),L < Len )-> 
                                  min_sols(Rs, L, R, Min,Sols, MinSols, Puzzle);
                                  min_sols(Rs, Len, CMin, Min, CSols, MinSols, Puzzle).
min_sols([R | Rs], Min, MinSols,Puzzle):- bagof(R,is_valid_row(R,Puzzle),Sols), 
                                       length(Sols, L),
                                       min_sols(Rs, L, R, Min, Sols, MinSols, Puzzle).

%construct and combine rows into a puzzle
make_rows([], _).
make_rows(Rows, Result):- min_sols(Rows, R, Sols,Result), select(R, Rows, Rs),
                          member(R, Sols),
                          make_rows(Rs, Result).
                                   
%check that the row is a valid construction by making sure all elements are
%valid and any flow on effects to other rows remain valid also
is_valid_row([H | R], Puzzle):- valid_els(R,Puzzle, [1,2,3,4,5,6,7,8,9]),
                      (sum_list(R, H);product_list(R, H)).
                      
valid_els([], _, _).
valid_els([E | Es], Puzzle, Valids):- member(E, Valids), check_rows(Puzzle),
                              select(E, Valids, NewVals),
                              valid_els(Es, Puzzle, NewVals).

%check that the rows remain sets (unique elements)
check_rows([]).
check_rows([_|Rows]):- row_sets(Rows).

row_sets([]).
row_sets([R | Rs]) :- is_set(R),row_sets(Rs).

%find the product of a list of numbers                                      
product_list([E|Es], Result):- product_list(Es, E, Result).
product_list([], Result, Result).
product_list([E|Es], A, Result):- NewA is E*A, product_list(Es, NewA, Result).
