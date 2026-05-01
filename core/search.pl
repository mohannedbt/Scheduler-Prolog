
:- use_module(library(lists)).
:- use_module(library(random)).

/* =====================================================
   MRV (Minimum Remaining Values)
   Select variable with smallest domain first
===================================================== */

select_mrv(Domains, Selected, Rest) :-
    Domains \= [],
    sort(2, @=<, Domains, Sorted),
    Sorted = [Selected | Rest].

/* =====================================================
   SAFE MRV (fallback-safe version)
===================================================== */

select_mrv_safe(Domains, Selected, Rest) :-
    (   Domains = []
    ->  fail
    ;   select_mrv(Domains, Selected, Rest)
    ).

/* =====================================================
   OPTIONAL: RANDOM VARIABLE SELECTION
   (useful for diversification)
===================================================== */

select_random(Domains, Selected, Rest) :-
    Domains \= [],
    random_member(Selected, Domains),
    delete(Domains, Selected, Rest).

/* =====================================================
   HEURISTIC SWITCH (future extension point)
===================================================== */

select_variable(mrv, Domains, Selected, Rest) :-
    select_mrv(Domains, Selected, Rest).

select_variable(random, Domains, Selected, Rest) :-
    select_random(Domains, Selected, Rest).