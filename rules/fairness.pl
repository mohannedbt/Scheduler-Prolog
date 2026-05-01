:- use_module(library(lists)).

/*
  Teacher workload extracted from a generated schedule.
  Workload is the number of assigned courses for each teacher.
*/

instructor_workload(Schedule, Teacher, Load) :-
    findall(C,
        (
            member(assign(C, _, _), Schedule),
            course(C, _, Teacher, _, _, _, _)
        ),
        Courses
    ),
    length(Courses, Load).

teacher_loads(Schedule, Loads) :-
    findall(Load,
        (
            teacher(T, _),
            instructor_workload(Schedule, T, Load)
        ),
        Loads
    ).

mean([], 0).
mean(List, Mean) :-
    sum_list(List, Sum),
    length(List, N),
    N > 0,
    Mean is Sum / N.

workload_variance(Schedule, Variance) :-
    teacher_loads(Schedule, Loads),
    mean(Loads, M),
    findall(D2,
        (
            member(L, Loads),
            D is L - M,
            D2 is D * D
        ),
        D2s
    ),
    mean(D2s, Variance).

workload_range(Schedule, Range) :-
    teacher_loads(Schedule, Loads),
    max_list(Loads, MaxL),
    min_list(Loads, MinL),
    Range is MaxL - MinL.

/*
  Lower score is better; combines variance and max-min spread.
*/
fairness_score(Schedule, Score) :-
    workload_variance(Schedule, Variance),
    workload_range(Schedule, Range),
    Score is Variance + Range.
