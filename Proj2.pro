%Project 2, COMP30020, Constantinos Kavadias, Student ID: 664790
%Unviersity of Melbourne, ckavadias@student.unimelb.edu.au, September 2017

%The following is verification/construction program to solve the problem of
%a "Puzzle". A Puzzle is valid given the the elements in each row/column are 
%unique from the other elements in that row/columm, the top left to bottom
%right diagonal contains the same digit in all cells, the rows/columns are the
%sum or product of the header(initial) element and all elements are >1 or <9.
:-ensure_loaded(library(clpfd)).
use_module(library(lists)).

puzzle_solution(Puzzle):- make_puzzle(Puzzle, Puzzle).

make_puzzle([H|Puzzle], Result):- make_rows(Puzzle, [H], Result).

%construct and combine rows into a puzzle
make_rows([], Result, Result).
make_rows([[H |R] | Rs], New, Result):- fill_row(R, R),
                                        (sum_list(R, H);product_list(R, H)),
                                        append(New, [[H |R]], Newer),
                                        make_rows(Rs, Newer, Result).

%find the product of a list of numbers                                      
product_list([E|Es], Result):- product_list(Es, E, Result).
product_list([], Result, Result).
product_list([E|Es], A, Result):- NewA is E*A, product_list(Es, NewA, Result).

fill_row(Es, Result):- find_els(Es, [], Result).

%construct a row of valid elements
find_els([], Result, Result).
find_els([E|Es], New, Result):- choose_el(E, New, E), 
                                append(New, [E], Newer),
                                find_els(Es, Newer, Result).

choose_el(E, Row, Result):- one_to_nine(E, 1, Row, Result).

%cycle through candidate elements until one that isn't in the row is found
one_to_nine(E, _, _, E):- ground(E).
one_to_nine(_, Candidate, Row, Candidate):- (\+member(Candidate, Row)).
one_to_nine(E, Candidate, Row, Result):- Candidate < 9 ->
                                         NewCan is Candidate + 1,
                                         one_to_nine(E, NewCan, Row, Result).
                                
%None of these are actually grounding the variables, need to redesign to allow
%grounding of all tems 

%Maybe construct the rows first