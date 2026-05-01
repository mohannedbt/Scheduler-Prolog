:- use_module(library(lists)).

solve(Schedule) :-
    findall(C, course(C, _, _, _, _, _, _), Courses),
    build_domains(Courses, Domains),
    search(Domains, [], Schedule).

build_domains([], []).
build_domains([Course | RestCourses], [Course-Domain | RestDomains]) :-
    findall(assign(Course, Room, Slot),
        valid_assignment(Course, Room, Slot),
        Domain),
    Domain \= [],
    build_domains(RestCourses, RestDomains).

valid_assignment(Course, Room, Slot) :-
    room(Room, _, _, _, _, _),
    slot(Slot, _, _),
    room_constraints_ok(assign(Course, Room, Slot)).

search([], Acc, Acc).
search(Domains, Acc, Schedule) :-
    select_mrv(Domains, _Course-Domain, Rest),
    member(Assign, Domain),
    consistent(Assign, Acc),
    search(Rest, [Assign | Acc], Schedule).

consistent(assign(C, R, S), ScheduleSoFar) :-
    room_constraints_ok(assign(C, R, S)),
    energy_ok_incremental(assign(C, R, S), ScheduleSoFar),
    \+ member(assign(_, R, S), ScheduleSoFar),
    \+ teacher_conflict(C, S, ScheduleSoFar),
    \+ group_conflict(C, S, ScheduleSoFar).

teacher_conflict(C, Slot, ScheduleSoFar) :-
    course(C, _, Teacher, _, _, _, _),
    member(assign(C2, _, Slot), ScheduleSoFar),
    course(C2, _, Teacher, _, _, _, _).

group_conflict(C, Slot, ScheduleSoFar) :-
    course_groups(C, Groups),
    member(assign(C2, _, Slot), ScheduleSoFar),
    course_groups(C2, Groups2),
    \+ disjoint(Groups, Groups2).