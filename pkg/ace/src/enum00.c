
/**************************************************************************

	enum00.c
	Colin Ramsay (cram@csee.uq.edu.au)
        25 Feb 00

	ADVANCED COSET ENUMERATOR, Version 3.001

	Copyright 2000
	Centre for Discrete Mathematics and Computing,
	Department of Mathematics and 
	  Department of Computer Science & Electrical Engineering,
	The University of Queensland, QLD 4072.
	(http://www.csee.uq.edu.au/~havas/cdmc.html)

This is the include file for the enumerator's finite automata.  The 
transition tables take the current state & the previous action's result, 
and give the next action & the next state.  Note that the complete state
machine also includes an initialisation phase & some special actions at the
exiting of a state with a particular result.  These are coded into the 
start of the _enum() function and a switch() at the end of the machine's 
main loop respectively.

States:
0	catch-all dummy/invalid state (forces return with fatal error)
1	initial state for start mode	R/C-style
2		--"--		     	R*-style
3		--"--		     	Cr-style
4		--"--		     	C*-style
5		--"--		     	reserved
6		--"--		     	C-style
7		--"--		     	Rc-style
8		--"--		     	R-style
9		--"--		     	CR-style
10	initial state for continue mode	R/C-style
11		--"--			R*-style
12		--"--			Cr-style
13		--"--			C*-style
14		--"--			reserved
15		--"--			C-style
16		--"--			Rc-style
17		--"--			R-style
18		--"--			CR-style
19	initial state for redo mode 	R/C-style
20		--"--		    	R*-style
21		--"--		    	Cr-style
22		--"--		    	C*-style
23		--"--		    	reserved
24		--"--		    	C-style
25		--"--		    	Rc-style
26		--"--		    	R-style
27		--"--		    	CR-style
28	RD in R-style
29	Lx in R-style
30	CO in R-style
31	Check phase (all styles)
32	CL in C-style
33	SG in C-style
34	RS in C-style
35	CD in C-style
36	CO in C-style
37	SG in R-style
38	CL in CR-style
39	SG in CR-style
40	RS in CR-style
41	CD in CR-style
42	CO in CR-style
43	RD in CR-style
44	SG in R/C-style
45	RD in R/C-style
46	CL in R/C-style
47	CL in Cr-style
48	SG in Cr-style
49	RS in Cr-style
50	CD in Cr-style
51	CO in Cr-style
52	RD in Cr-style
53	SG in Rc-style
54	RD in Rc-style
55	CL in Rc-style
56	CL in Rc-style
57	CO in Rc-style
58	CD in Rc-style
59	CL in R*-style
60	SG in R*-style
61	RP in R*-style
62	CO in R*-style

Results (internal):
0	unable to make definition (overflow)
-1	success (continue)
-2	finite result (potential index)	

Actions (may cause state machine exit & force return from al0_enum()):
-1	catch-all dummy/invalid action (forces return with fatal error)
0	null action (always succeeds)
1	definitions (R-style)
2	lookahead (R-style)
3	compaction (any style; no space forces overflow return)
4	definitions/deductions (C-style)
5	lookahead (C-style)
6	check finite result (always returns; index or incomplete table)
7	apply subgroup generators to coset 1 (overflow returns -260)
8	apply relators to coset 1
9	definitions/deductions (R*-style)

**************************************************************************/

static int al0_act[63][3] =
  { 
    {-1, -1, -1},	/*  0 */
    {-1,  7, -1},	/*  1 */
    {-1,  7, -1},	/*  2 */
    {-1,  7, -1},	/*  3 */
    {-1, -1, -1},	/*  4 */
    {-1, -1, -1},	/*  5 */
    {-1,  7, -1},	/*  6 */
    {-1,  7, -1},	/*  7 */
    {-1,  7, -1},	/*  8 */
    {-1,  7, -1},	/*  9 */
    {-1,  1, -1},	/* 10 */
    {-1,  9, -1},	/* 11 */
    {-1,  4, -1},	/* 12 */
    {-1, -1, -1},	/* 13 */
    {-1, -1, -1},	/* 14 */
    {-1,  4, -1},	/* 15 */
    {-1,  1, -1},	/* 16 */
    {-1,  1, -1},	/* 17 */
    {-1,  4, -1},	/* 18 */
    {-1,  7, -1},	/* 19 */
    {-1,  5, -1},	/* 20 */
    {-1,  5, -1},	/* 21 */
    {-1, -1, -1},	/* 22 */
    {-1, -1, -1},	/* 23 */
    {-1,  5, -1},	/* 24 */
    {-1,  7, -1},	/* 25 */
    {-1,  7, -1},	/* 26 */
    {-1,  5, -1},	/* 27 */
    { 2,  1,  6},	/* 28 */
    {-1,  3,  6},	/* 29 */
    {-1,  1, -1},	/* 30 */
    {-1, -1, -1},	/* 31 */
    {-1,  7,  6},	/* 32 */
    {-1,  8,  6},	/* 33 */
    { 4,  4,  6},	/* 34 */
    { 3,  4,  6},	/* 35 */
    {-1,  4, -1},	/* 36 */
    {-1,  1,  6},	/* 37 */
    {-1,  7,  6},	/* 38 */
    {-1,  8,  6},	/* 39 */
    { 4,  4,  6},	/* 40 */
    { 3,  1,  6},	/* 41 */
    {-1,  1, -1},	/* 42 */
    { 4,  4,  6},	/* 43 */
    {-1,  1,  6},	/* 44 */
    { 5,  1,  6},	/* 45 */
    {-1,  4,  6},	/* 46 */
    {-1,  7,  6},	/* 47 */
    {-1,  8,  6},	/* 48 */
    { 4,  4,  6},	/* 49 */
    { 3,  1,  6},	/* 50 */
    {-1,  1, -1},	/* 51 */
    { 4,  4,  6},	/* 52 */
    {-1,  1,  6},	/* 53 */
    { 5,  5,  6},	/* 54 */
    {-1,  3,  6},	/* 55 */
    {-1,  4,  6},	/* 56 */
    {-1,  4, -1},	/* 57 */
    { 3,  1,  6},	/* 58 */
    {-1,  7,  6},	/* 59 */
    {-1,  9,  6},	/* 60 */
    { 3,  9,  6},	/* 61 */
    {-1,  9, -1}	/* 62 */
  };

static int al0_st[63][3] =
  {
    { 0,  0,  0},	/*  0 */
    { 0, 44,  0},	/*  1 */
    { 0, 60,  0},	/*  2 */
    { 0, 48,  0},	/*  3 */
    { 0,  0,  0},	/*  4 */
    { 0,  0,  0},	/*  5 */
    { 0, 33,  0},	/*  6 */
    { 0, 53,  0},	/*  7 */
    { 0, 37,  0},	/*  8 */
    { 0, 39,  0},	/*  9 */
    { 0, 45,  0},	/* 10 */
    { 0, 61,  0},	/* 11 */
    { 0, 50,  0},	/* 12 */
    { 0,  0,  0},	/* 13 */
    { 0,  0,  0},	/* 14 */
    { 0, 35,  0},	/* 15 */
    { 0, 54,  0},	/* 16 */
    { 0, 28,  0},	/* 17 */
    { 0, 41,  0},	/* 18 */
    { 0, 44,  0},	/* 19 */
    { 0, 59,  0},	/* 20 */
    { 0, 47,  0},	/* 21 */
    { 0,  0,  0},	/* 22 */
    { 0,  0,  0},	/* 23 */
    { 0, 32,  0},	/* 24 */
    { 0, 53,  0},	/* 25 */
    { 0, 37,  0},	/* 26 */
    { 0, 38,  0},	/* 27 */
    {29, 28, 31},	/* 28 */
    { 0, 30, 31},	/* 29 */
    { 0, 28,  0},	/* 30 */
    { 0,  0,  0},	/* 31 */
    { 0, 33, 31},	/* 32 */
    { 0, 34, 31},	/* 33 */
    {35, 35, 31},	/* 34 */
    {36, 35, 31},	/* 35 */
    { 0, 35,  0},	/* 36 */
    { 0, 28, 31},	/* 37 */
    { 0, 39, 31},	/* 38 */
    { 0, 40, 31},	/* 39 */
    {41, 41, 31},	/* 40 */
    {42, 43, 31},	/* 41 */
    { 0, 43,  0},	/* 42 */
    {41, 41, 31},	/* 43 */
    { 0, 45, 31},	/* 44 */
    {46, 45, 31},	/* 45 */
    { 0, 41, 31},	/* 46 */
    { 0, 48, 31},	/* 47 */
    { 0, 49, 31},	/* 48 */
    {50, 50, 31},	/* 49 */
    {51, 52, 31},	/* 50 */
    { 0, 52,  0},	/* 51 */
    {35, 35, 31},	/* 52 */
    { 0, 54, 31},	/* 53 */
    {55, 56, 31},	/* 54 */
    { 0, 57, 31},	/* 55 */
    { 0, 58, 31},	/* 56 */
    { 0, 58,  0},	/* 57 */
    {30, 28, 31},	/* 58 */
    { 0, 60, 31},	/* 59 */
    { 0, 61, 31},	/* 60 */
    {62, 61, 31},	/* 61 */
    { 0, 61,  0}	/* 62 */
  };

