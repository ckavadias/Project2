%Project 2, COMP30020, Constantinos Kavadias, Student ID: 664790
%Unviersity of Melbourne, ckavadias@student.unimelb.edu.au, September 2017

%The following is verification/construction program to solve the problem of
%a "Puzzle". A Puzzle is valid given the the elements in each row/column are 
%unique from the other elements in that row/columm, the top left to bottom
%right diagonal contains the same digit in all cells, the rows/columns are the
%sum or product of the header(initial) element and all elements are >1 or <9.
:-ensure_loaded(library(clpfd)).
use_module(library(lists)).

puzzle_solution(Puzzle):- link_diagonal(Puzzle),
                          make_puzzle(Puzzle, Puzzle).

%bind diagonal's to eachother, also check that the diagonals aren't repeated
%within their own rows as this automatically implies failure
link_diagonal([[_, H], [H, H]]).
link_diagonal([_, A, B]):- (A = [_, X, _]), (B = [_, _, X]),
                                    is_set(A), is_set(B).
link_diagonal([_, A, B, C]):- (A = [_, X | _]), (B = [_, _, X, _]),
                                          (C = [_, _, _, X]),
                                          is_set(A), is_set(B), is_set(C).

make_puzzle([_|Puzzle], Result):- make_rows(Puzzle, Result).

%check that the row can achieve a sum/product goal
check_rows([]).
check_rows([R | Rs]):- maybe_valid(R), check_rows(Rs).

check_sp([], Remaining,_, _) :- length(Remaining, Length), Length > 7.
check_sp([], [L | Rem], Sum, Prod) :- last(Rem, M),((Sum >= L) , (Sum =< M);
                                      (Prod >= L),(Prod =< M)).

check_sp([E|Es], Remaining, Sum, Prod):- ground(E) -> 
                                   NewSum is Sum - E,
                                   NewProd is Prod/E,
                                   select(E, Remaining, NewRem),
                                   check_sp(Es, NewRem, NewSum, NewProd);
                                   check_sp(Es, Remaining, Sum, Prod).
                                  
maybe_valid([H |Es]):- check_sp(Es,[1,2,3,4,5,6,7,8,9], H, H).

%construct and combine rows into a puzzle
make_rows([], Result, Result).
make_rows([[H |R] | Rs], Result):- fill_row(R, R, Result),
                                   (sum_list(R, H);product_list(R, H)),
                                   make_rows(Rs, Result).

%find the product of a list of numbers                                      
product_list([E|Es], Result):- product_list(Es, E, Result).
product_list([], Result, Result).
product_list([E|Es], A, Result):- NewA is E*A, product_list(Es, NewA, Result).


fill_row(Es, Result, Puzzle):- is_set(Es),find_els(Es, Es, Result, Puzzle).

%construct a row of valid elements
find_els([], Result, Result, _).
find_els([E|Es], Row, Result, [H|Puzzle]):- choose_cand(Row, Cand),
                                choose_el(E,Cand, E), link_diagonal([H|Puzzle]),
                                check_rows(Puzzle), find_els(Es, Row, Result).

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
                                