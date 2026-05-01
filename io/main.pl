% =====================================================
% MAIN ENTRY POINT
% Consult-based loader (no project modules).
% =====================================================

:- dynamic(project_root/1).

:- prolog_load_context(file, ThisFile),
   file_directory_name(ThisFile, IoDir),
   directory_file_path(IoDir, '..', Root0),
   absolute_file_name(Root0, Root, [file_type(directory)]),
   asserta(project_root(Root)).

:- initialization(load_all).

load_all :-
    project_root(Root),
    consult_project(Root),
    ready_message.

consult_project(Root) :-
    consult_rel(Root, 'core/domain.pl'),
    consult_rel(Root, 'core/helpers.pl'),
    consult_rel(Root, 'core/search.pl'),

    consult_rel(Root, 'rules/room_constraints.pl'),
    consult_rel(Root, 'rules/energy.pl'),
    consult_rel(Root, 'rules/fairness.pl'),

    consult_rel(Root, 'core/solver.pl'),

    consult_rel(Root, 'engine/evaluation_engine.pl'),
    consult_rel(Root, 'engine/optimizer.pl'),

    consult_rel(Root, 'io/exports.pl').

consult_rel(Root, RelPath) :-
    directory_file_path(Root, RelPath, FullPath),
    consult(FullPath).

ready_message :-
    nl,
    write('========================================'), nl,
    write('   PROJECT LOADED SUCCESSFULLY'), nl,
    write('   You can now run:'), nl,
    write('   ?- solve(S).'), nl,
    write('   ?- best_schedule(B).'), nl,
    write('   ?- pareto_top3(P).'), nl,
    write('   ?- explain_score(S).   % after solve/1'), nl,
    write('========================================'), nl,
    nl.