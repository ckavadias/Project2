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

make_puzzle([H|Puzzle]):- make_rows(Puzzle, [H|Puzzle]).

%check that the row can achieve a sum/product goal
check_rows(Rows):- row_sets(Rows),valid_rows(Rows).

row_sets([]).
row_sets([R | Rs]) :- is_set(R),row_sets(Rs).

valid_rows([]).
valid_rows([R | Rs]) :- maybe_valid(R),valid_rows(Rs).
maybe_valid([H |Es]):- length(Es,L),check_sp(Es,L, [1,2,3,4,5,6,7,8,9], H, H).

check_sp([], Len, Rem,S, P) :- length(Rem, L), (L =:= 9 - Len), (S = 0 ; P = 1).
check_sp([],Len, Rem,_, _) :- length(Rem, L), L > (9 - Len + 1).
check_sp([],_, Rem, Sum, Prod) :- length(Rem, L), L < 9,
                                  member(Sum, Rem) ; member(Prod, Rem).

check_sp([E|Es],Len, Remaining, Sum, Prod):- ground(E) -> 
                                   NewSum is Sum - E,
                                   NewProd is Prod/E,
                                   select(E, Remaining, NewRem),
                                   check_sp(Es, Len,NewRem, NewSum, NewProd);
                                   check_sp(Es, Len,Remaining, Sum, Prod).

%construct and combine rows into a puzzle
make_rows([], _).
make_rows([[H |R] | Rs], Result):- fill_row(R, Result),
                                   (sum_list(R, H);product_list(R, H)),
                                   make_rows(Rs, Result).

%find the product of a list of numbers                                      
product_list([E|Es], Result):- product_list(Es, E, Result).
product_list([], Result, Result).
product_list([E|Es], A, Result):- NewA is E*A, product_list(Es, NewA, Result).

%start to allocate elements to empty rows
fill_row(Es, Puzzle):- is_set(Es),find_els(Es, Es, Puzzle).

%construct a row of valid elements
find_els([], _, _).
find_els([E|Es], Row, [H|Puzzle]):- choose_cand(Row, Cand),
                                choose_el(E,Cand, E),
                                check_rows(Puzzle), 
                                transpose([H|Puzzle],[_|TPuz]),check_rows(TPuz),
                                find_els(Es, Row, [H|Puzzle]).

choose_el(E, [C | Cs], Result):- ground(E) ->  Result is E;
                                 one_to_nine(C,Cs, Result).

%determine what are candidate elements
choose_cand(Row, Candidates):- fix_cand([1,2,3,4,5,6,7,8,9],Row,Candidates).

fix_cand(Candidates, [], Candidates).
fix_cand(Temp, [E | Es], Candidates) :- ground(E) -> select(E, Temp, NewTemp),
                                        fix_cand(NewTemp, Es, Candidates);
                                        fix_cand(Temp, Es, Candidates).

%cycle through candidate elements
one_to_nine(Candidate, _,Candidate).
one_to_nine(_, [C|Cands], Result):- one_to_nine(C, Cands, Result).
                                