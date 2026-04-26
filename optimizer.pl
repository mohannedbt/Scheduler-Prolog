:- module(optimizer, [
    score_all/2,
    best_schedule/1,
    pareto_top3/1,
    schedule_diff/3,
    why_assigned/3,
    generate_candidates/2
]).

:- ensure_loaded('solver.pl').
:- use_module('metrics.pl').
:- use_module(library(solution_sequences)).

/*
  Generate up to Max feasible schedules via Prolog backtracking.
*/
generate_candidates(Max, Schedules) :-
    findnsols(Max, S, solve(S), Schedules).

score_all(Schedules, Scored) :-
    findall(Score-S,
        (
            member(S, Schedules),
            score(S, Score)
        ),
        Scored).

best_schedule(BestSchedule) :-
    generate_candidates(25, Schedules),
    Schedules \= [],
    score_all(Schedules, Scored),
    keysort(Scored, [ _BestScore-BestSchedule | _ ]).

/*
  Pareto-style top 3 profiles:
  - best energy
  - best fairness
  - best total weighted score
*/
pareto_top3([best_energy-EnergyBest, best_fairness-FairBest, best_balanced-TotalBest]) :-
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
        ES),
    keysort(ES, [_-Best | _]).

best_by_fairness(Schedules, Best) :-
    findall(F-S,
        (
            member(S, Schedules),
            compute_fairness_score(S, F)
        ),
        FS),
    keysort(FS, [_-Best | _]).

schedule_diff(S1, S2, Differences) :-
    findall(C-(R1,Slt1)->(R2,Slt2),
        (
            member(assign(C, R1, Slt1), S1),
            member(assign(C, R2, Slt2), S2),
            (R1 \== R2 ; Slt1 \== Slt2)
        ),
        Differences).

why_assigned(Course, Schedule, Explanation) :-
    member(assign(Course, Room, Slot), Schedule),
    course(Course, Filiere, Teacher, RequiredEquip, SessionType, Duration, Priority),
    room(Room, Capacity, RoomEquip, RoomType),
    course_groups(Course, Gs),
    total_size(Gs, GroupSize),
    slot(Slot, Day, Hour),
    format(atom(Explanation),
        'course=~w filiere=~w teacher=~w slot=~w(~w ~w:00) room=~w(type=~w,equip=~w,cap=~w) needs(equip=~w,type=~w,duration=~w,priority=~w) group_size=~w',
        [Course, Filiere, Teacher, Slot, Day, Hour, Room, RoomType, RoomEquip, Capacity, RequiredEquip, SessionType, Duration, Priority, GroupSize]
    ).
