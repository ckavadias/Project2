%Project 2, COMP30020, Constantinos Kavadias, Student ID: 664790
%Unviersity of Melbourne, ckavadias@student.unimelb.edu.au, September 2017

%The following is verification/construction program to solve the problem of
%a "Puzzle". A Puzzle is valid given the the elements in each row/column are 
%unique from the other elements in that row/columm, the top left to bottom
%right diagonal contains the same digit in all cells, the rows/columns are the
%sum or product of the header(initial) element and all elements are >1 or <9.
:-ensure_loaded(library(clpfd)).
use_module(library(lists)).

puzzle_solution(Puzzle):- link_diagonal(Puzzle, Puzzle),
                          make_puzzle(Puzzle, Puzzle).
                          
link_diagonal([_, _], [[_, H], [H, H]]).
link_diagonal([_,_,_], [_, [_, X, _], [_, _, X]]).
link_diagonal([_,_,_, _], [_, [_, X | _], [_, _, X | _], [_, _, _, X]]).

make_puzzle([_|Puzzle], Result):- make_rows(Puzzle, Result).

%construct and combine rows into a puzzle
make_rows([], Result, Result).
make_rows([[H |R] | Rs], Result):- fill_row(R, R),
                                        (sum_list(R, H);product_list(R, H)),
                                        make_rows(Rs, Result).

%find the product of a list of numbers                                      
product_list([E|Es], Result):- product_list(Es, E, Result).
product_list([], Result, Result).
product_list([E|Es], A, Result):- NewA is E*A, product_list(Es, NewA, Result).


fill_row(Es, Result):- is_set(Es),find_els(Es, Es, Result).

%construct a row of valid elements
find_els([], Result, Result).
find_els([E|Es], Row, Result):- choose_cand(Row, Cand),choose_el(E,Cand, E), 
                                find_els(Es, Row, Result).

choose_el(E, [C | Cs], Result):- ground(E) ->  Result is E;
                                 one_to_nine(C,Cs, Result).

%determine what are candidate elements
choose_cand(Row, Candidates):- fix_cand([1,2,3,4,5,6,7,8,9],Row,Candidates).

fix_cand(Candidates, [], Candidates).
fix_cand(Temp, [E | Es], Candidates) :- ground(E) -> select(E, Temp, NewTemp),
                                        fix_cand(NewTemp, Es, Candidates);
                                        fix_cand(Temp, Es, Candidates).
add_cand([], Result, _, Result).
add_cand([C | Cs], Current, Row, Result) :- (\+member(C, Row)) ->
                                            append(Current, [C], NewCur),
                                            add_cand(Cs, NewCur, Row, Result);
                                            add_cand(Cs, Current, Row, Result).
%cycle through candidate elements
one_to_nine(Candidate, _,Candidate).
one_to_nine(_, [C|Cands], Result):- one_to_nine(C, Cands, Result).
                                