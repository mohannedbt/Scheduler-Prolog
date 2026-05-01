

export_txt(File) :-
    best_schedule(S),
    open(File, write, Stream),
    write(Stream, '=== TIMETABLE ===\n'),
    write_txt(S, Stream),
    close(Stream).

write_txt([], _).
write_txt([assign(C,R,S)|T], Stream) :-
    format(Stream, "~w -> ~w @ ~w~n", [C,R,S]),
    write_txt(T, Stream).

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