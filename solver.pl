
:- consult(room_constraints).
:- consult(energy).


/* =====================================================
   FILIERES
===================================================== */

filiere(cs).
filiere(ing).
filiere(ai).
filiere(ds).
filiere(se).
filiere(math).

/* =====================================================
   GROUPS (UNCHANGED)
===================================================== */

group(g1, cs, 25).
group(g2, cs, 20).
group(g3, cs, 25).
group(g4, ing, 18).
group(g5, ing, 20).
group(g6, ai, 22).
group(g7, ai, 18).
group(g8, cs, 30).
group(g9, cs, 28).
group(g10, ing, 24).
group(g11, ing, 26).
group(g12, ai, 30).
group(g13, ai, 27).
group(g14, ds, 35).
group(g15, ds, 40).
group(g16, se, 32).
group(g17, se, 28).
group(g18, math, 45).
group(g19, math, 38).

/* =====================================================
   TEACHERS
===================================================== */

teacher(t1, 3).
teacher(t2, 3).
teacher(t3, 3).
teacher(t4, 4).
teacher(t5, 3).
teacher(t6, 3).
teacher(t7, 2).
teacher(t8, 3).
teacher(t9, 4).
teacher(t10, 3).
teacher(t11, 3).

/* =====================================================
   CORE COURSES (expanded per filière)
===================================================== */

/* CS */
course(cs_algo, cs, t1, projector, lecture, 2, high).
course(cs_algo_lab, cs, t1, lab_pc, exercise, 2, high).
course(cs_db, cs, t2, projector, lecture, 2, high).
course(cs_networks, cs, t4, projector, lecture, 2, medium).
course(cs_web, cs, t5, whiteboard, lecture, 2, medium).
course(cs_os, cs, t6, projector, lecture, 2, high).
course(cs_ai_intro, cs, t3, projector, lecture, 2, medium).

/* AI */
course(ai_math, ai, t3, projector, lecture, 2, high).
course(ai_ml, ai, t4, projector, lecture, 2, high).
course(ai_ml_lab, ai, t4, lab_pc, exercise, 2, high).
course(ai_dl, ai, t8, projector, lecture, 2, high).
course(ai_data, ai, t9, lab_pc, exercise, 2, medium).
course(ai_nlp, ai, t3, projector, lecture, 2, medium).

/* ING */
course(ing_math, ing, t5, whiteboard, lecture, 2, high).
course(ing_physics, ing, t3, whiteboard, exercise, 2, medium).
course(ing_circuits, ing, t6, lab_pc, exercise, 2, high).
course(ing_mechanics, ing, t7, whiteboard, lecture, 2, medium).
course(ing_design, ing, t10, projector, lecture, 2, medium).

/* DS */
course(ds_intro, ds, t10, projector, lecture, 2, high).
course(ds_stats, ds, t11, whiteboard, lecture, 2, high).
course(ds_bigdata, ds, t4, lab_pc, exercise, 2, high).
course(ds_ml, ds, t8, projector, lecture, 2, high).
course(ds_viz, ds, t9, lab_pc, exercise, 2, medium).

/* SE */
course(se_intro, se, t11, projector, lecture, 2, high).
course(se_arch, se, t6, projector, lecture, 2, high).
course(se_dev, se, t7, lab_pc, exercise, 2, high).
course(se_testing, se, t8, lab_pc, exercise, 2, medium).
course(se_project, se, t9, whiteboard, lecture, 2, medium).

/* MATH */
course(math_analysis, math, t1, whiteboard, lecture, 2, high).
course(math_algebra, math, t2, whiteboard, lecture, 2, high).
course(math_stats, math, t3, whiteboard, lecture, 2, high).
course(math_prob, math, t4, whiteboard, lecture, 2, medium).
course(math_discrete, math, t5, whiteboard, lecture, 2, high).

/* =====================================================
   ROOMS (UNCHANGED)
===================================================== */

room(amphi1, 150, projector, amphi,  b1, 12).
room(amphi2, 120, projector, amphi,  b1, 12).
room(amphi3, 180, projector, amphi,  b2, 14).
room(amphi4, 200, projector, amphi,  b2, 14).
room(lab1,    40, lab_pc,    lab,    b1, 28).
room(lab2,    35, lab_pc,    lab,    b1, 28).
room(lab3,    45, lab_pc,    lab,    b2, 30).
room(lab4,    60, lab_pc,    lab,    b2, 30).
room(class1,  60, whiteboard, class, b1,  8).
room(class2,  50, whiteboard, class, b1,  8).
room(class3,  70, whiteboard, class, b2,  9).
room(class4,  80, whiteboard, class, b2,  9).

/* =====================================================
   TIMESLOTS (UNCHANGED)
===================================================== */

slot(s1,mon,8).   slot(s2,mon,10).  slot(s3,mon,14).
slot(s4,tue,8).   slot(s5,tue,10).  slot(s6,tue,14).
slot(s7,wed,8).   slot(s8,wed,10).  slot(s9,wed,14).
slot(s10,thu,8).  slot(s11,thu,10). slot(s12,thu,14).
slot(s13,fri,8).  slot(s14,fri,10). slot(s15,fri,14).
slot(s16,mon,16). slot(s17,tue,16). slot(s18,wed,16).
slot(s19,thu,16). slot(s20,fri,16).

/* =====================================================
   HELPERS
===================================================== */

group_size(G,S) :- group(G,_,S).

groups_of(F,Gs) :- findall(G, group(G,F,_), Gs).

total_size(Gs,T) :-
    findall(S,(member(G,Gs),group_size(G,S)),L),
    sum_list(L,T).

course_groups(C,Gs) :-
    course(C,F,_,_,_,_,_),
    groups_of(F,Gs).

/* =====================================================
   PROGRESS COUNTER
===================================================== */

:- dynamic(counter/1).
reset_counter :- retractall(counter(_)), assert(counter(0)).

inc_counter :-
    retract(counter(N)),
    N1 is N + 1,
    assert(counter(N1)),
    (N1 mod 200 =:= 0 ->
        format("\r🔄 nodes explored: ~w", [N1])
    ; true).

/* =====================================================
   VALID ASSIGNMENTS
===================================================== */

valid(C, assign(C,R,S)) :-
    slot(S, _, _),
    room(R, _, _, _, _, _),
    equipment_ok(C, R),
    capacity_ok(C, R).

/* =====================================================
   BUILD DOMAINS
===================================================== */

build_domains([], []).
build_domains([C|Cs], [C-D|Rest]) :-
    findall(A, valid(C,A), D),
    D \= [],
    build_domains(Cs, Rest).

/* =====================================================
   CONSTRAINTS
===================================================== */

consistent(assign(C,R,S), Sched) :-
    room_constraints_ok(assign(C,R,S)),          
    energy_ok_incremental(assign(C,R,S), Sched), 
    \+ member(assign(_,R,S), Sched),
    course(C,_,T,_,_,_,_),
    \+ (member(assign(C2,_,S),Sched), course(C2,_,T,_,_,_,_)),
    course_groups(C,Gs),
    \+ (member(assign(C2,_,S),Sched), course_groups(C2,Gs2), \+disjoint(Gs,Gs2)).

disjoint([], _).
disjoint([H|T],L) :- \+ member(H,L), disjoint(T,L).

/* =====================================================
   MRV
===================================================== */

select_mrv(Domains, C-Domain, Rest) :-
    sort(2, @=<, Domains, Sorted),
    Sorted = [C-Domain|Rest].

/* =====================================================
   GLOBAL COMPLETENESS CHECK
===================================================== */

all_assigned([], _).
all_assigned([C|Cs], S) :-
    member(assign(C,_,_), S),
    all_assigned(Cs, S).

/* =====================================================
   SOLVER
===================================================== */

solve(Solution) :-
    reset_counter,
    findall(C, course(C,_,_,_,_,_,_), Cs),
    build_domains(Cs, Domains),
    search(Domains, [], Solution),
    all_assigned(Cs, Solution),
    nl, write('✅ COMPLETE SCHEDULE FOUND'), nl.

/* =====================================================
   SEARCH
===================================================== */

search([], Acc, Acc).

search(Domains, Acc, Sol) :-
    select_mrv(Domains, C-Domain, Rest),
    member(Assign, Domain),
    inc_counter,
    consistent(Assign, Acc),
    search(Rest, [Assign|Acc], Sol).

/* =====================================================
   EXPORT TXT
===================================================== */

export_txt(File) :-
    solve(S),
    open(File, write, Stream),
    write(Stream, '=== TIMETABLE ===\n'),
    write_txt(S, Stream),
    close(Stream).

write_txt([], _).
write_txt([assign(C,R,S)|T], Stream) :-
    format(Stream, "~w -> ~w @ ~w~n", [C,R,S]),
    write_txt(T, Stream).

/* =====================================================
   EXPORT HTML
===================================================== */

export_html(File) :-
    solve(S),
    open(File, write, Stream),

    write(Stream, '<html><body><h2>Timetable</h2>'),
    write(Stream, '<table border="1" cellpadding="5">'),
    write(Stream, '<tr><th>Course</th><th>Room</th><th>Slot</th></tr>'),

    write_html(S, Stream),

    write(Stream, '</table></body></html>'),
    close(Stream).

write_html([], _).
write_html([assign(C,R,S)|T], Stream) :-
    format(Stream,
        '<tr><td>~w</td><td>~w</td><td>~w</td></tr>',
        [C,R,S]),
    write_html(T, Stream).