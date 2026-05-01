:- use_module(library(lists)).

% =====================================================
% ENERGY SCORE
% =====================================================

compute_energy_score(Schedule, Score) :-
    total_energy(Schedule, Score).

% =====================================================
% FAIRNESS SCORE (teacher workload balance)
% =====================================================

compute_fairness_score(Schedule, Score) :-
    fairness_score(Schedule, Score).

% =====================================================
% GAP SCORE (temporal dispersion per filiere)
% =====================================================

course_filiere(Course, Filiere) :-
    atomic_list_concat([Filiere | _], '_', Course).

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
    findall(F,
        (
            member(assign(C, _, _), Schedule),
            course_filiere(C, F)
        ),
        Fs0
    ),
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

% =====================================================
% COMPACTNESS SCORE
% =====================================================

compute_compactness_score(Schedule, Score) :-
    compute_gap_score(Schedule, GapScore),
    length(Schedule, N),
    Score is GapScore + (0.1 * N).

% =====================================================
% TRAVEL SCORE (penalize building changes within a day)
% =====================================================

room_changes([], 0).
room_changes([_], 0).
room_changes([R1, R2 | T], Changes) :-
    (R1 == R2 -> C is 0 ; C is 1),
    room_changes([R2 | T], Rest),
    Changes is C + Rest.

room_building(Room, Building) :-
    room(Room, _, _, _, Building, _).

filiere_day_buildings(Schedule, Filiere, Day, BuildingsByTime) :-
    findall(H-B,
        (
            member(assign(C, Room, S), Schedule),
            course_filiere(C, Filiere),
            slot(S, Day, H),
            room_building(Room, B)
        ),
        Pairs
    ),
    keysort(Pairs, Sorted),
    findall(B, member(_-B, Sorted), BuildingsByTime).

compute_travel_score(Schedule, Score) :-
    findall(F,
        (
            member(assign(C, _, _), Schedule),
            course_filiere(C, F)
        ),
        Fs0
    ),
    sort(Fs0, Filieres),
    findall(P,
        (
            member(F, Filieres),
            member(Day, [mon, tue, wed, thu, fri]),
            filiere_day_buildings(Schedule, F, Day, Buildings),
            room_changes(Buildings, P)
        ),
        Penalties
    ),
    sum_list(Penalties, Score).

% =====================================================
% PEAK SCORE (count late sessions)
% =====================================================

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

% =====================================================
% FINAL SCORE (weighted)
% =====================================================

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
