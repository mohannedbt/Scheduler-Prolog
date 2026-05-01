

:- use_module(library(lists)).

/* =====================================================
   ROOM CONSTRAINTS — Student B
   File: room_constraints.pl
===================================================== */

/* =====================================================
   BUILDINGS
===================================================== */

building(b1, main_campus,   200, 0.4).
building(b2, science_wing,  180, 0.2).
% building(Id, Name, MaxDailyEnergy, RenewableRatio)

/* =====================================================
   MAINTENANCE — rooms unavailable on certain days
===================================================== */

room_maintenance(lab3, wed).
room_maintenance(class2, fri).

/* =====================================================
   EQUIPMENT COMPATIBILITY
   A room can host a course if its equipment
   is compatible with the course requirement.
===================================================== */

equipment_compatible(projector,  projector).
equipment_compatible(lab_pc,     lab_pc).
equipment_compatible(whiteboard, whiteboard).
equipment_compatible(projector,  whiteboard).  % projector room can host whiteboard course
equipment_compatible(lab_pc,     whiteboard).  % lab can host whiteboard course too

/* =====================================================
   STEP 2A — equipment_ok/2
   Check that the room equipment fits the course need.
===================================================== */

equipment_ok(Course, Room) :-
    course(Course, _, _, CourseEquip, _, _, _),
    room(Room, _, RoomEquip, _, _, _),
    equipment_compatible(RoomEquip, CourseEquip).

/* =====================================================
   STEP 2B — capacity_ok/2
   Check that the room fits ALL groups of the filière.
===================================================== */


capacity_ok(Course, Room) :-
    course(Course, Filiere, _, _, Type, _, _),
    room(Room, Cap, _, _, _, _),
    required_capacity(Filiere, Type, Required),
    Cap >= Required.

% Lecture: entire filière attends together
required_capacity(Filiere, lecture, Total) :-
    groups_of(Filiere, Gs),
    total_size(Gs, Total).

% Exercise/Lab: one group at a time (use largest group)
required_capacity(Filiere, exercise, MaxSize) :-
    groups_of(Filiere, Gs),
    findall(S, (member(G, Gs), group_size(G, S)), Sizes),
    max_list(Sizes, MaxSize).

/* =====================================================
   STEP 2C — room_available/2
   Room must not be under maintenance on that day.
===================================================== */

room_available(Room, Slot) :-
    slot(Slot, Day, _),
    \+ room_maintenance(Room, Day).

/* =====================================================
   STEP 2D — room_constraints_ok/2
   Master predicate — called from consistent/3
   Bundles all 3 checks above.
===================================================== */

room_constraints_ok(assign(Course, Room, Slot)) :-
    equipment_ok(Course, Room),
    capacity_ok(Course, Room),
    room_available(Room, Slot).