
:- use_module(library(lists)).


/* =====================================================
   STEP 1 — BUILDING ENERGY THRESHOLD
===================================================== */

effective_threshold(Building, EffMax) :-
    building(Building, _, Emax, Ratio),
    EffMax is Emax * (1 + Ratio).

/* =====================================================
   STEP 2 — PEAK HOUR MULTIPLIER
===================================================== */

peak_multiplier(Slot, 1.2) :-
    slot(Slot, _, Hour),
    Hour >= 14,
    !.

peak_multiplier(_, 1.0).

/* =====================================================
   STEP 3 — INTERNAL ENERGY MODEL (CONSTRAINT VIEW)
   Used ONLY for constraint checking
===================================================== */

assignment_energy(assign(Course, Room, _Slot), Energy) :-
    course(Course, _, _, _, _, Duration, _),
    room(Room, _, _, _, _, EnergyPerHour),
    Energy is EnergyPerHour * Duration.

/* =====================================================
   STEP 4 — DAILY ENERGY ACCUMULATION
===================================================== */

daily_energy(Building, Day, Schedule, Total) :-
    daily_energy_acc(Building, Day, Schedule, 0, Total).

daily_energy_acc(_, _, [], Acc, Acc).

daily_energy_acc(Building, Day, [assign(C, R, S) | Rest], Acc, Total) :-
    slot(S, Day, _),
    room(R, _, _, _, Building, _),
    !,
    assignment_energy(assign(C, R, S), E),
    peak_multiplier(S, Mult),
    Cost is E * Mult,
    NewAcc is Acc + Cost,
    daily_energy_acc(Building, Day, Rest, NewAcc, Total).

daily_energy_acc(Building, Day, [_ | Rest], Acc, Total) :-
    daily_energy_acc(Building, Day, Rest, Acc, Total).

/* =====================================================
   STEP 5 — HARD CONSTRAINT (FINAL CHECK)
===================================================== */

energy_ok(Building, Day, Schedule) :-
    daily_energy(Building, Day, Schedule, Used),
    effective_threshold(Building, EffMax),
    Used =< EffMax.

/* =====================================================
   STEP 6 — INCREMENTAL CONSTRAINT (SEARCH PRUNING)
===================================================== */

energy_ok_incremental(assign(C, R, S), CurrentSchedule) :-
    slot(S, Day, _),
    room(R, _, _, _, Building, _),
    daily_energy(Building, Day,
        [assign(C, R, S) | CurrentSchedule],
        Projected),
    effective_threshold(Building, EffMax),
    Projected =< EffMax.
% =====================================================
% GLOBAL ENERGY SCORE (FOR EVALUATION ENGINE)
% =====================================================

total_energy(Schedule, Total) :-
    findall(E,
        (
            member(assign(C, R, S), Schedule),
            assignment_energy(assign(C, R, S), Base),
            peak_multiplier(S, Mult),
            E is Base * Mult
        ),
        Energies
    ),
    sum_list(Energies, Total).