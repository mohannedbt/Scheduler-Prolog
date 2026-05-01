

% =====================================================
% DOMAIN — PURE DATA LAYER
% =====================================================

/* FILIERES */
filiere(cs).
filiere(ing).
filiere(ai).
filiere(ds).
filiere(se).
filiere(math).

/* GROUPS */
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

/* TEACHERS */
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

/* COURSES */
course(cs_algo, cs, t1, projector, lecture, 2, high).
course(cs_algo_lab, cs, t1, lab_pc, exercise, 2, high).
course(cs_db, cs, t2, projector, lecture, 2, high).
course(cs_networks, cs, t4, projector, lecture, 2, medium).
course(cs_web, cs, t5, whiteboard, lecture, 2, medium).
course(cs_os, cs, t6, projector, lecture, 2, high).
course(cs_ai_intro, cs, t3, projector, lecture, 2, medium).

course(ai_math, ai, t3, projector, lecture, 2, high).
course(ai_ml, ai, t4, projector, lecture, 2, high).
course(ai_ml_lab, ai, t4, lab_pc, exercise, 2, high).
course(ai_dl, ai, t8, projector, lecture, 2, high).
course(ai_data, ai, t9, lab_pc, exercise, 2, medium).
course(ai_nlp, ai, t3, projector, lecture, 2, medium).

course(ing_math, ing, t5, whiteboard, lecture, 2, high).
course(ing_physics, ing, t3, whiteboard, exercise, 2, medium).
course(ing_circuits, ing, t6, lab_pc, exercise, 2, high).
course(ing_mechanics, ing, t7, whiteboard, lecture, 2, medium).
course(ing_design, ing, t10, projector, lecture, 2, medium).

course(ds_intro, ds, t10, projector, lecture, 2, high).
course(ds_stats, ds, t11, whiteboard, lecture, 2, high).
course(ds_bigdata, ds, t4, lab_pc, exercise, 2, high).
course(ds_ml, ds, t8, projector, lecture, 2, high).
course(ds_viz, ds, t9, lab_pc, exercise, 2, medium).

course(se_intro, se, t11, projector, lecture, 2, high).
course(se_arch, se, t6, projector, lecture, 2, high).
course(se_dev, se, t7, lab_pc, exercise, 2, high).
course(se_testing, se, t8, lab_pc, exercise, 2, medium).
course(se_project, se, t9, whiteboard, lecture, 2, medium).

course(math_analysis, math, t1, whiteboard, lecture, 2, high).
course(math_algebra, math, t2, whiteboard, lecture, 2, high).
course(math_stats, math, t3, whiteboard, lecture, 2, high).
course(math_prob, math, t4, whiteboard, lecture, 2, medium).
course(math_discrete, math, t5, whiteboard, lecture, 2, high).

/* ROOMS */
room(amphi1, 150, projector, amphi,  b1, 12).
room(amphi2, 120, projector, amphi,  b1, 12).
room(amphi3, 180, projector, amphi,  b2, 14).
room(amphi4, 200, projector, amphi,  b2, 14).
room(lab1,    40, lab_pc,    lab,    b1, 50).
room(lab2,    35, lab_pc,    lab,    b1, 28).
room(lab3,    45, lab_pc,    lab,    b2, 30).
room(lab4,    60, lab_pc,    lab,    b2, 30).
room(class1,  60, whiteboard, class, b1,  8).
room(class2,  50, whiteboard, class, b1,  8).
room(class3,  70, whiteboard, class, b2,  9).
room(class4,  80, whiteboard, class, b2,  9).

/* SLOTS */
slot(s1,mon,8).   slot(s2,mon,10).  slot(s3,mon,14).
slot(s4,tue,8).   slot(s5,tue,10).  slot(s6,tue,14).
slot(s7,wed,8).   slot(s8,wed,10).  slot(s9,wed,14).
slot(s10,thu,8).  slot(s11,thu,10). slot(s12,thu,14).
slot(s13,fri,8).  slot(s14,fri,10). slot(s15,fri,14).
slot(s16,mon,16). slot(s17,tue,16). slot(s18,wed,16).
slot(s19,thu,16). slot(s20,fri,16).