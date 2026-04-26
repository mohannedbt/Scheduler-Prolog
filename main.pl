:- module(main, [
    run_system/2,
    print_schedule/1,
    print_weekly_by_filiere/1
]).

:- use_module('optimizer.pl').
:- use_module('metrics.pl').
:- ensure_loaded('solver.pl').

run_system(Best, Report) :-
    best_schedule(Best),
    score(Best, TotalScore),
    length(Best, Count),
    Report = report{assignments:Count, total_score:TotalScore},
    format('Best schedule found with ~w assignments. Total score: ~2f~n', [Count, TotalScore]).

print_schedule(Schedule) :-
    sort(3, @=<, Schedule, BySlot),
    forall(member(assign(C, R, S), BySlot),
        (
            slot(S, Day, Hour),
            format('~w -> ~w @ ~w (~w ~w:00)~n', [C, R, S, Day, Hour])
        )
    ).

print_weekly_by_filiere(Schedule) :-
    findall(F, (member(assign(C, _, _), Schedule), course_filiere(C, F)), Fs0),
    sort(Fs0, Filieres),
    forall(member(F, Filieres),
        (
            format('~n=== ~w ===~n', [F]),
            forall(
                member(Day, [mon, tue, wed, thu, fri]),
                (
                    format('~w: ', [Day]),
                    print_filiere_day(Schedule, F, Day),
                    nl
                )
            )
        )
    ).

course_filiere(Course, Filiere) :-
    atom(Course),
    atomic_list_concat([Filiere|_], '_', Course).

print_filiere_day(Schedule, Filiere, Day) :-
    findall(H-C-R,
        (
            member(assign(C, R, S), Schedule),
            course_filiere(C, Filiere),
            slot(S, Day, H)
        ),
        Triples
    ),
    keysort(Triples, Sorted),
    (   Sorted = []
    ->  write('no sessions')
    ;   forall(member(H-C-R, Sorted), format('[~w:00 ~w in ~w] ', [H, C, R]))
    ).
