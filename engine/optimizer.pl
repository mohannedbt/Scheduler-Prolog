:- use_module(library(lists)).
:- use_module(library(solution_sequences)).

generate_candidates(Max, Schedules) :-
    findnsols(Max, S, solve(S), Raw),
    sort(Raw, Schedules).

best_schedule(BestSchedule) :-
    generate_candidates(25, Schedules),
    Schedules \= [],
    findall(Score-S,
        (
            member(S, Schedules),
            score(S, Score)
        ),
        Scored
    ),
    keysort(Scored, [_BestScore-BestSchedule | _]).

pareto_top3([
    best_energy-EnergyBest,
    best_fairness-FairBest,
    best_balanced-TotalBest
]) :-
    generate_candidates(30, Schedules),
    Schedules \= [],
    best_by_energy(Schedules, EnergyBest),
    best_by_fairness(Schedules, FairBest),
    best_schedule(TotalBest).

best_by_energy(Schedules, Best) :-
    findall(E-S,
        (
            member(S, Schedules),
            compute_energy_score(S, E)
        ),
        ES
    ),
    keysort(ES, [_-Best | _]).

best_by_fairness(Schedules, Best) :-
    findall(F-S,
        (
            member(S, Schedules),
            compute_fairness_score(S, F)
        ),
        FS
    ),
    keysort(FS, [_-Best | _]).


