/* =====================================================
   ENERGY SYSTEM — Student B
   File: energy.pl
===================================================== */

/* =====================================================
   STEP 3A — assignment_energy/2
   Energy cost of ONE assignment.
   Uses EnergyPerHour from room fact + course Duration.
===================================================== */

assignment_energy(assign(Course, Room, _Slot), Energy) :-
    course(Course, _, _, _, _, Duration, _),
    room(Room, _, _, _, _, EnergyPerHour),
    Energy is EnergyPerHour * Duration.

/* =====================================================
   STEP 3B — peak_energy_cost/2
   Afternoon slots (14:00, 16:00) cost 20% more.
   Returns a multiplier.
===================================================== */

peak_multiplier(Slot, 1.2) :-
    slot(Slot, _, Hour),
    Hour >= 14,
    !.
peak_multiplier(_, 1.0).

/* =====================================================
   STEP 3C — effective_threshold/2
   Buildings with renewable energy get a bonus:
   effective max = Emax * (1 + RenewableRatio)
===================================================== */

effective_threshold(Building, EffMax) :-
    building(Building, _, Emax, Ratio),
    EffMax is Emax * (1 + Ratio).

/* =====================================================
   STEP 3D — daily_energy/4
   Sum energy of all assignments in a building on a day.
   Uses accumulator pattern (Chapter 4).
===================================================== */

daily_energy(Building, Day, Schedule, Total) :-
    daily_energy_acc(Building, Day, Schedule, 0, Total).

daily_energy_acc(_, _, [], Acc, Acc).

daily_energy_acc(Building, Day, [assign(C, R, S) | Rest], Acc, Total) :-
    slot(S, Day, _),                          % this slot is on that day
    room(R, _, _, _, Building, _),            % room is in that building
    !,
    assignment_energy(assign(C, R, S), E),
    peak_multiplier(S, Mult),
    Cost is E * Mult,
    NewAcc is Acc + Cost,
    daily_energy_acc(Building, Day, Rest, NewAcc, Total).

daily_energy_acc(Building, Day, [_ | Rest], Acc, Total) :-
    daily_energy_acc(Building, Day, Rest, Acc, Total).

/* =====================================================
   STEP 3E — total_energy/2
   Sum energy across ALL buildings and ALL days.
===================================================== */

total_energy(Schedule, Total) :-
    findall(E,
        (building(B, _, _, _),
         member(Day, [mon, tue, wed, thu, fri]),
         daily_energy(B, Day, Schedule, E)),
        Energies),
    sum_list(Energies, Total).

/* =====================================================
   STEP 3F — energy_ok/3
   Hard constraint: building daily energy ≤ threshold.
   Called during schedule construction (not after!).
===================================================== */

energy_ok(Building, Day, Schedule) :-
    daily_energy(Building, Day, Schedule, Used),
    effective_threshold(Building, EffMax),
    Used =< EffMax.

/* =====================================================
   STEP 3G — energy_warning/3
   Soft flag: warn if building is at > 80% capacity.
===================================================== */

energy_warning(Building, Day, Schedule) :-
    daily_energy(Building, Day, Schedule, Used),
    effective_threshold(Building, EffMax),
    Threshold80 is EffMax * 0.8,
    Used > Threshold80,
    format("⚠️  Warning: ~w on ~w is at ~2f / ~2f energy~n",
           [Building, Day, Used, EffMax]).

/* =====================================================
   STEP 3H — energy_report/1
   Print full energy breakdown per building per day.
   Call after solving: ?- solve(S), energy_report(S).
===================================================== */

energy_report(Schedule) :-
    write('=== ENERGY REPORT ==='), nl,
    forall(
        building(B, Name, _, _),
        (   format("~n📍 Building: ~w (~w)~n", [B, Name]),
            effective_threshold(B, EffMax),
            format("   Effective max: ~2f~n", [EffMax]),
            forall(
                member(Day, [mon, tue, wed, thu, fri]),
                (   daily_energy(B, Day, Schedule, E),
                    format("   ~w : ~2f units~n", [Day, E])
                )
            )
        )
    ),
    total_energy(Schedule, Total),
    format("~n🔋 TOTAL WEEKLY ENERGY: ~2f units~n", [Total]).

/* =====================================================
*/


energy_ok_incremental(assign(C, R, S), CurrentSchedule) :-
    slot(S, Day, _),
    room(R, _, _, _, Building, _),
    % simulate adding this assignment and check threshold
    daily_energy(Building, Day, [assign(C,R,S)|CurrentSchedule], Projected),
    effective_threshold(Building, EffMax),
    Projected =< EffMax.