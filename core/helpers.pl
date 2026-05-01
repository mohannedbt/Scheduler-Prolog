:- use_module(library(lists)).

group_size(G, S) :-
    group(G, _, S).

groups_of(F, Gs) :-
    findall(G, group(G, F, _), Gs).

total_size(Gs, T) :-
    findall(S, (member(G, Gs), group_size(G, S)), L),
    sum_list(L, T).

course_groups(C, Gs) :-
    course(C, F, _, _, _, _, _),
    groups_of(F, Gs).

disjoint([], _).
disjoint([H|T], L) :-
    \+ member(H, L),
    disjoint(T, L).

normalize(S, Flat) :-
    (   is_list(S),
        S = [X],
        is_list(X)
    ->  Flat = X
    ;   Flat = S
    ).