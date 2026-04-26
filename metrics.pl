:- module(metrics, [
    compute_energy_score/2,
    compute_gap_score/2,
    compute_fairness_score/2,
    compute_compactness_score/2,
    compute_travel_score/2,
    compute_peak_score/2,
    score/2,
    explain_score/1
]).

:- ensure_loaded('solver.pl').
:- use_module('fairness.pl', [compute_fairness_score/2]).

/*
  This repository does not yet define per-room energy facts.
  We estimate energy from room capacity and slot period to keep
  the optimizer functional without changing Student A/B/C files.
*/

room_energy_factor(Room, Factor) :-
    room(Room, Capacity, _, _),
    Factor is Capacity / 20.

slot_peak_multiplier(Slot, Mult) :-
    slot(Slot, _, Hour),
    (Hour >= 14 -> Mult = 1.2 ; Mult = 1.0).

assignment_energy(assign(_, Room, Slot), Energy) :-
    room_energy_factor(Room, Base),
    slot_peak_multiplier(Slot, Mult),
    Energy is Base * Mult.

compute_energy_score(Schedule, Score) :-
    findall(E, (member(A, Schedule), assignment_energy(A, E)), Es),
    sum_list(Es, Score).

course_filiere(Course, Filiere) :-
    atom(Course),
    atomic_list_concat([Filiere|_], '_', Course).

filiere_day_hours(Schedule, Filiere, Day, SortedHours) :-
    findall(H,
        (
            member(assign(C, _, S), Schedule),
            course_filiere(C, Filiere),
            slot(S, Day, H)
        ),
        Hours
    ),
    sort(Hours, SortedHours).

list_gaps([], 0).
list_gaps([_], 0).
list_gaps([H1, H2 | T], Gaps) :-
    Delta is H2 - H1,
    Gap is max(0, (Delta // 2) - 1),
    list_gaps([H2 | T], Rest),
    Gaps is Gap + Rest.

compute_gap_score(Schedule, Score) :-
    findall(F, (member(assign(C, _, _), Schedule), course_filiere(C, F)), Fs0),
    sort(Fs0, Filieres),
    findall(G,
        (
            member(F, Filieres),
            member(Day, [mon, tue, wed, thu, fri]),
            filiere_day_hours(Schedule, F, Day, Hours),
            list_gaps(Hours, G)
        ),
        Gaps
    ),
    sum_list(Gaps, Score).

/*
  Compactness is mostly the opposite of gaps.
  We keep both because they can be weighted differently.
*/
compute_compactness_score(Schedule, Score) :-
    compute_gap_score(Schedule, GapScore),
    length(Schedule, N),
    Score is GapScore + (0.1 * N).

room_changes([], 0).
room_changes([_], 0).
room_changes([R1, R2 | T], Changes) :-
    (R1 == R2 -> C is 0 ; C is 1),
    room_changes([R2 | T], Rest),
    Changes is C + Rest.

filiere_day_rooms(Schedule, Filiere, Day, RoomsByTime) :-
    findall(H-R,
        (
            member(assign(C, R, S), Schedule),
            course_filiere(C, Filiere),
            slot(S, Day, H)
        ),
        Pairs
    ),
    keysort(Pairs, Sorted),
    findall(Room, member(_-Room, Sorted), RoomsByTime).

compute_travel_score(Schedule, Score) :-
    findall(F, (member(assign(C, _, _), Schedule), course_filiere(C, F)), Fs0),
    sort(Fs0, Filieres),
    findall(P,
        (
            member(F, Filieres),
            member(Day, [mon, tue, wed, thu, fri]),
            filiere_day_rooms(Schedule, F, Day, Rooms),
            room_changes(Rooms, P)
        ),
        Penalties
    ),
    sum_list(Penalties, Score).

compute_peak_score(Schedule, Score) :-
    findall(1,
        (
            member(assign(_, _, S), Schedule),
            slot(S, _, H),
            H >= 14
        ),
        Peaks
    ),
    length(Peaks, Score).

/*
  Lower is better.
  Weights can be tuned later without changing optimizer logic.
*/
score(Schedule, Total) :-
    compute_energy_score(Schedule, Energy),
    compute_gap_score(Schedule, Gaps),
    compute_fairness_score(Schedule, Fairness),
    compute_compactness_score(Schedule, Compactness),
    compute_travel_score(Schedule, Travel),
    compute_peak_score(Schedule, Peak),
    Total is
        0.35 * Energy +
        0.15 * Gaps +
        0.20 * Fairness +
        0.10 * Compactness +
        0.10 * Travel +
        0.10 * Peak.

explain_score(Schedule) :-
    compute_energy_score(Schedule, Energy),
    compute_gap_score(Schedule, Gaps),
    compute_fairness_score(Schedule, Fairness),
    compute_compactness_score(Schedule, Compactness),
    compute_travel_score(Schedule, Travel),
    compute_peak_score(Schedule, Peak),
    score(Schedule, Total),
    format('Energy score      : ~2f~n', [Energy]),
    format('Gap score         : ~2f~n', [Gaps]),
    format('Fairness score    : ~2f~n', [Fairness]),
    format('Compactness score : ~2f~n', [Compactness]),
    format('Travel score      : ~2f~n', [Travel]),
    format('Peak score        : ~2f~n', [Peak]),
    format('TOTAL             : ~2f~n', [Total]).
