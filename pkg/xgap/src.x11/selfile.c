/****************************************************************************
**
*W  selfile.c                   XGAP Source              Erik M. van der Poel
*W                                                   modified by Frank Celler
**
*H  @(#)$Id: selfile.c,v 1.6 2011/11/24 11:44:23 gap Exp $
**
**  This file is based on the file selector  distributed with  ghostview,  it
**  contained the following notice:
**
*Y  Copyright 1989,       Software Research Associates Inc.,  Tokyo,    Japan
**
**  Permission to  use, copy,  modify,  and distribute this  software and its
**  documentation for any purpose and without fee is hereby granted, provided
**  that the above copyright notice  appear in all copies  and that both that
**  copyright notice  and   this  permission  notice appear  in    supporting
**  documentation, and  that the name  of Software Research Associates not be
**  used  in advertising  or  publicity  pertaining  to distribution   of the
**  software without  specific, written prior permission.   Software Research
**  Associates   makes no  representations  about   the suitability  of  this
**  software for  any  purpose.  It  is provided "as   is" without express or
**  implied warranty.
**
**  SOFTWARE RESEARCH ASSOCIATES DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
**  SOFTWARE,  INCLUDING  ALL  IMPLIED  WARRANTIES    OF  MERCHANTABILITY AND
**  FITNESS, IN NO EVENT SHALL SOFTWARE RESEARCH ASSOCIATES BE LIABLE FOR ANY
**  SPECIAL, INDIRECT  OR  CONSEQUENTIAL DAMAGES  OR  ANY  DAMAGES WHATSOEVER
**  RESULTING FROM LOSS OF   USE, DATA OR  PROFITS, WHETHER  IN AN  ACTION OF
**  CONTRACT,  NEGLIGENCE OR  OTHER TORTIOUS  ACTION,  ARISING OUT  OF  OR IN
**  CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
** 
**  Author: Erik M. van der Poel
**          Software Research Associates, Inc., Tokyo, Japan
**          erik@sra.co.jp
**
**  Author's address:
** 
**      erik@sra.co.jp
**                                             OR
**      erik%sra.co.jp@uunet.uu.net
**                                             OR
**      erik%sra.co.jp@mcvax.uucp
**                                             OR
**      try junet instead of co.jp
**                                             OR
**      Erik M. van der Poel
**      Software Research Associates, Inc.
**      1-1-1 Hirakawa-cho, Chiyoda-ku
**      Tokyo 102 Japan. TEL +81-3-234-2692
*/
#ifndef NO_FILE_SELECTOR

#ifdef hpux
#   define USG
#endif

#include    "utils.h"

#if HAVE_DIRENT_H
# include <dirent.h>
# define NAMLEN(dirent) strlen((dirent)->d_name)
#else
# define dirent direct
# define NAMLEN(dirent) (dirent)->d_namlen
# if HAVE_SYS_NDIR_H
#  include <sys/ndir.h>
# endif
# if HAVE_SYS_DIR_H
#  include <sys/dir.h>
# endif
# if HAVE_NDIR_H
#  include <ndir.h>
# endif
#endif


#include "selfile.h"

#define SEL_FILE_CANCEL		-1
#define SEL_FILE_OK		0
#define SEL_FILE_NULL		1
#define SEL_FILE_TEXT		2

#define SF_DO_SCROLL		1
#define SF_DO_NOT_SCROLL	0


/****************************************************************************
**

*T  Typedefs  . . . . . . . . . . . . . . . . . . .  various private typedefs
*/
typedef struct {
	int	statDone;
	char	*real;
	char	*shown;
} SFEntry;

typedef struct {
	char	*dir;
	char	*path;
	SFEntry	*entries;
	int	nEntries;
	int	vOrigin;
	int	nChars;
	int	hOrigin;
	int	changed;
	int	beginSelection;
	int	endSelection;
	time_t	mtime;
} SFDir;

static void
	SFenterList(),
	SFleaveList(),
	SFmotionList(),
	SFbuttonPressList(),
	SFbuttonReleaseList();

static void
	SFvSliderMovedCallback(),
	SFvFloatSliderMovedCallback(),
	SFhSliderMovedCallback(),
	SFpathSliderMovedCallback(),
	SFvAreaSelectedCallback(),
	SFhAreaSelectedCallback(),
	SFpathAreaSelectedCallback();

static Boolean SFworkProc();

static int SFcompareEntries();

static void SFdirModTimer();

static char SFstatChar();


/* BSD 4.3 errno.h does not declare errno */
extern int errno;
/* extern int sys_nerr; */

#if !defined(S_ISDIR) && defined(S_IFDIR)
#define S_ISDIR(m) (((m) & S_IFMT) == S_IFDIR)
#endif
#if !defined(S_ISREG) && defined(S_IFREG)
#define S_ISREG(m) (((m) & S_IFMT) == S_IFREG)
#endif
#if !defined(S_ISSOCK) && defined(S_IFSOCK)
#define S_ISSOCK(m) (((m) & S_IFMT) == S_IFSOCK)
#endif

#ifndef S_IXUSR
#define S_IXUSR 0100
#endif
#ifndef S_IXGRP
#define S_IXGRP 0010
#endif
#ifndef S_IXOTH
#define S_IXOTH 0001
#endif

#define S_ISXXX(m) ((m) & (S_IXUSR | S_IXGRP | S_IXOTH))

#ifndef MAXPATHLEN
#define MAXPATHLEN 1024
#endif /* ndef MAXPATHLEN */

#if !defined(SVR4) && !defined(SYSV) && !defined(USG)
extern char *getwd();
#endif /* !defined(SVR4) && !defined(SYSV) && !defined(USG) */

#if defined(SVR4) || defined(SYSV) || defined(USG)
extern uid_t getuid();
extern void qsort();
#endif /* defined(SVR4) || defined(SYSV) || defined(USG) */

static int SFstatus = SEL_FILE_NULL;

static char
	SFstartDir[MAXPATHLEN],
	SFcurrentPath[MAXPATHLEN],
	SFcurrentDir[MAXPATHLEN];

static Widget
	selFile,
	selFileCancel,
	selFileField,
	selFileForm,
	selFileHScroll,
	selFileHScrolls[3],
	selFileLists[3],
	selFileOK,
        selFileHome,
	selFilePrompt,
	selFileVScrolls[3];

static Display *SFdisplay = 0;

static Pixel SFfore, SFback;

static Atom	SFwmDeleteWindow;

static XSegment SFsegs[2], SFcompletionSegs[2];

static XawTextPosition SFtextPos;

static int SFupperX, SFlowerY, SFupperY;

static int SFtextX, SFtextYoffset;

static int SFentryWidth, SFentryHeight;

static int SFlineToTextH = 3;

static int SFlineToTextV = 3;

static int SFbesideText = 3;

static int SFaboveAndBelowText = 2;

static int SFcharsPerEntry = 15;

static int SFlistSize = 10;

static int SFworkProcAdded = 0;

static XtAppContext SFapp;

static int SFpathScrollWidth, SFvScrollHeight, SFhScrollWidth;

static char SFtextBuffer[MAXPATHLEN];

static XtIntervalId SFdirModTimerId;

static int (*SFfunc)( String, String*, struct stat* ) = 0;


#if defined(SVR4) || defined(SYSV) || defined(USG)
extern void qsort();
#endif /* defined(SVR4) || defined(SYSV) || defined(USG) */

static SFDir *SFdirs = NULL;

static int SFdirEnd;

static int SFdirPtr;

static int SFbuttonPressed = 0;

static int SFdoNotTouchDirPtr = 0;

static int SFdoNotTouchVorigin = 0;

static SFDir SFrootDir, SFhomeDir;

typedef struct {
        char    *name;
        char    *dir;
} SFLogin;

static SFLogin *SFlogins;

static int SFtwiddle = 0;



/****************************************************************************
**
*F  SFcompareEntries( <p>, <q> )  . . . . . . . . . .  compare two sf entries
*/
static int SFcompareEntries ( p, q )
    SFEntry   * p;
    SFEntry   * q;
{
    return strcmp(p->real, q->real);
}


static int SFgetDir( dir )
    SFDir     * dir;
{
    SFEntry		*result = NULL;
    int		alloc = 0;
    int		i;
    DIR		*dirp;
    struct dirent	*dp;
    char		*str;
    int		len;
    int		maxChars;
    struct stat	statBuf;

    maxChars = strlen(dir->dir) - 1;

    dir->entries = NULL;
    dir->nEntries = 0;
    dir->nChars = 0;

    result = NULL;
    i = 0;

    dirp = opendir(".");
    if (!dirp) {
	return 1;
    }

    (void) stat(".", &statBuf);
    dir->mtime = statBuf.st_mtime;

    (void) readdir(dirp);	/* throw away "." */

#ifndef S_IFLNK
    (void) readdir(dirp);	/* throw away ".." */
#endif /* ndef S_IFLNK */

    while ( (dp=readdir(dirp)) ) {
	if (i >= alloc) {
	    alloc = 2 * (alloc + 1);
	    result = (SFEntry *) XtRealloc((char *) result,
				(unsigned) (alloc * sizeof(SFEntry)));
	}
	result[i].statDone = 0;
	str = dp->d_name;
	len = strlen(str);
	result[i].real = XtMalloc((unsigned) (len + 2));
	(void) strcat(strcpy(result[i].real, str), " ");
	if (len > maxChars) {
	    maxChars = len;
	}
	result[i].shown = result[i].real;
	i++;
    }

#if defined(SVR4) || defined(SYSV) || defined(USG)
    qsort((char *) result, (unsigned) i, sizeof(SFEntry), SFcompareEntries);
#else /* defined(SVR4) || defined(SYSV) || defined(USG) */
    qsort((char *) result, i, sizeof(SFEntry), SFcompareEntries);
#endif /* defined(SVR4) || defined(SYSV) || defined(USG) */

    dir->entries = result;
    dir->nEntries = i;
    dir->nChars = maxChars + 1;

    closedir(dirp);

    return 0;
}

static char *oneLineTextEditTranslations = "\
	<Key>Return:	redraw-display()\n\
	Ctrl<Key>M:	redraw-display()\n\
";

#define SF_DEFAULT_FONT "9x15"

#ifdef ABS
#undef ABS
#endif
#define ABS(x) (((x) < 0) ? (-(x)) : (x))

typedef struct {
	char *fontname;
} TextData, *textPtr;

int SFcharWidth, SFcharAscent, SFcharHeight;

int SFcurrentInvert[3] = { -1, -1, -1 };

static GC SFlineGC, SFscrollGC, SFinvertGC, SFtextGC;

static XtResource textResources[] = {
	{XtNfont, XtCFont, XtRString, sizeof (char *),
		XtOffset(textPtr, fontname), XtRString, SF_DEFAULT_FONT},
};

static XFontStruct *SFfont;

static int SFcurrentListY;

static XtIntervalId SFscrollTimerId;

void SFinitFont()
{
	TextData	*data;

	data = XtNew(TextData);

	XtGetApplicationResources(selFileForm, (XtPointer) data, textResources,
		XtNumber(textResources), (Arg *) NULL, ZERO);

	SFfont = XLoadQueryFont(SFdisplay, data->fontname);
	if (!SFfont) {
		SFfont = XLoadQueryFont(SFdisplay, SF_DEFAULT_FONT);
		if (!SFfont) {
			char	sbuf[256];

			(void) sprintf(sbuf, "XsraSelFile: can't get font %s",
				SF_DEFAULT_FONT);

			XtAppError(SFapp, sbuf);
		}
	}

	SFcharWidth = (SFfont->max_bounds.width + SFfont->min_bounds.width) / 2;
	SFcharAscent = SFfont->max_bounds.ascent;
	SFcharHeight = SFcharAscent + SFfont->max_bounds.descent;
}

void SFcreateGC()
{
	XGCValues	gcValues;
	XRectangle	rectangles[1];

	gcValues.foreground = SFfore;

	SFlineGC = XtGetGC(
		selFileLists[0],
		(XtGCMask)
			GCForeground		|
			0,
		&gcValues
	);

	SFscrollGC = XtGetGC(
		selFileLists[0],
		(XtGCMask)
			0,
		&gcValues
	);

	gcValues.function = GXinvert;
	gcValues.plane_mask = (SFfore ^ SFback);

	SFinvertGC = XtGetGC(
		selFileLists[0],
		(XtGCMask)
			GCFunction		|
			GCPlaneMask		|
			0,
		&gcValues
	);

	gcValues.foreground = SFfore;
	gcValues.background = SFback;
	gcValues.font = SFfont->fid;

	SFtextGC = XCreateGC(
		SFdisplay,
		XtWindow(selFileLists[0]),
		(unsigned long)
			GCForeground		|
			GCBackground		|
			GCFont			|
			0,
		&gcValues
	);

	rectangles[0].x = SFlineToTextH + SFbesideText;
	rectangles[0].y = 0;
	rectangles[0].width = SFcharsPerEntry * SFcharWidth;
	rectangles[0].height = SFupperY + 1;

	XSetClipRectangles(
		SFdisplay,
		SFtextGC,
		0,
		0,
		rectangles,
		1,
		Unsorted
	);
}

void SFclearList(n, doScroll)
	int	n;
	int	doScroll;
{
	SFDir	*dir;

	SFcurrentInvert[n] = -1;

	XClearWindow(SFdisplay, XtWindow(selFileLists[n]));

	XDrawSegments(SFdisplay, XtWindow(selFileLists[n]), SFlineGC, SFsegs,
		2);

	if (doScroll) {
		dir = &(SFdirs[SFdirPtr + n]);

		if ((SFdirPtr + n < SFdirEnd) && dir->nEntries && dir->nChars) {
			XawScrollbarSetThumb(
				selFileVScrolls[n],
				(float) (((double) dir->vOrigin) /
					dir->nEntries),
				(float) (((double) ((dir->nEntries < SFlistSize)
					? dir->nEntries : SFlistSize)) /
					dir->nEntries)
			);

			XawScrollbarSetThumb(
				selFileHScrolls[n],
				(float) (((double) dir->hOrigin) / dir->nChars),
				(float) (((double) ((dir->nChars <
					SFcharsPerEntry) ? dir->nChars :
					SFcharsPerEntry)) / dir->nChars)
			);
		} else {
			XawScrollbarSetThumb(selFileVScrolls[n], (float) 0.0,
				(float) 1.0);
			XawScrollbarSetThumb(selFileHScrolls[n], (float) 0.0,
				(float) 1.0);
		}
	}
}

static void
SFdeleteEntry(dir, entry)
	SFDir	*dir;
	SFEntry	*entry;
{
	register SFEntry	*e;
	register SFEntry	*end;
	int			n;
	int			idx;

	idx = entry - dir->entries;

	if (idx < dir->beginSelection) {
		dir->beginSelection--;
	}
	if (idx <= dir->endSelection) {
		dir->endSelection--;
	}
	if (dir->beginSelection > dir->endSelection) {
		dir->beginSelection = dir->endSelection = -1;
	}

	if (idx < dir->vOrigin) {
		dir->vOrigin--;
	}

	XtFree(entry->real);

	end = &(dir->entries[dir->nEntries - 1]);

	for (e = entry; e < end; e++) {
		*e = *(e + 1);
	}

	if (!(--dir->nEntries)) {
		return;
	}

	n = dir - &(SFdirs[SFdirPtr]);
	if ((n < 0) || (n > 2)) {
		return;
	}

	XawScrollbarSetThumb(
		selFileVScrolls[n],
		(float) (((double) dir->vOrigin) / dir->nEntries),
		(float) (((double) ((dir->nEntries < SFlistSize) ?
			dir->nEntries : SFlistSize)) / dir->nEntries)
	);
}

static void
SFwriteStatChar(name, last, statBuf)
	char		*name;
	int		last;
	struct stat	*statBuf;
{
	name[last] = SFstatChar(statBuf);
}

static int SFchdir(path)
	char	*path;
{
	int	result;

	result = 0;

	if (strcmp(path, SFcurrentDir)) {
		result = chdir(path);
		if (!result) {
			(void) strcpy(SFcurrentDir, path);
		}
	}

	return result;
}

static int
SFstatAndCheck(dir, entry)
	SFDir	*dir;
	SFEntry	*entry;
{
	struct stat	statBuf;
	char		save;
	int		last;

	/*
	 * must be restored before returning
	 */
	save = *(dir->path);
	*(dir->path) = 0;

	if (!SFchdir(SFcurrentPath)) {
		last = strlen(entry->real) - 1;
		entry->real[last] = 0;
		entry->statDone = 1;
		if (
			(!stat(entry->real, &statBuf))

#ifdef S_IFLNK

		     || (!lstat(entry->real, &statBuf))

#endif /* ndef S_IFLNK */

		) {
			if (SFfunc) {
				char *shown;

				shown = NULL;
				if (SFfunc(entry->real, &shown, &statBuf)) {
					if (shown) {
						int len;

						len = strlen(shown);
						entry->shown = XtMalloc(
							(unsigned) (len + 2)
						);
						(void) strcpy(entry->shown,
							shown);
						SFwriteStatChar(
							entry->shown,
							len,
							&statBuf
						);
						entry->shown[len + 1] = 0;
					}
				} else {
					SFdeleteEntry(dir, entry);

					*(dir->path) = save;
					return 1;
				}
			}
			SFwriteStatChar(entry->real, last, &statBuf);
		} else {
			entry->real[last] = ' ';
		}
	}

	*(dir->path) = save;
	return 0;
}

static void
SFdrawStrings(w, dir, from, to)
	register Window	w;
	register SFDir	*dir;
	register int	from;
	register int	to;
{
	register int		i;
	register SFEntry	*entry;
	int			x;

	x = SFtextX - dir->hOrigin * SFcharWidth;

	if (dir->vOrigin + to >= dir->nEntries) {
		to = dir->nEntries - dir->vOrigin - 1;
	}
	for (i = from; i <= to; i++) {
		entry = &(dir->entries[dir->vOrigin + i]);
		if (!(entry->statDone)) {
			if (SFstatAndCheck(dir, entry)) {
				if (dir->vOrigin + to >= dir->nEntries) {
					to = dir->nEntries - dir->vOrigin - 1;
				}
				i--;
				continue;
			}
		}
		XDrawImageString(
			SFdisplay,
			w,
			SFtextGC,
			x,
			SFtextYoffset + i * SFentryHeight,
			entry->shown,
			strlen(entry->shown)
		);
		if (dir->vOrigin + i == dir->beginSelection) {
			XDrawLine(
				SFdisplay,
				w,
				SFlineGC,
				SFlineToTextH + 1,
				SFlowerY + i * SFentryHeight,
				SFlineToTextH + SFentryWidth - 2,
				SFlowerY + i * SFentryHeight
			);
		}
		if (
			(dir->vOrigin + i >= dir->beginSelection) &&
			(dir->vOrigin + i <= dir->endSelection)
		) {
			SFcompletionSegs[0].y1 = SFcompletionSegs[1].y1 =
				SFlowerY + i * SFentryHeight;
			SFcompletionSegs[0].y2 = SFcompletionSegs[1].y2 =
				SFlowerY + (i + 1) * SFentryHeight - 1;
			XDrawSegments(
				SFdisplay,
				w,
				SFlineGC,
				SFcompletionSegs,
				2
			);
		}
		if (dir->vOrigin + i == dir->endSelection) {
			XDrawLine(
				SFdisplay,
				w,
				SFlineGC,
				SFlineToTextH + 1,
				SFlowerY + (i + 1) * SFentryHeight - 1,
				SFlineToTextH + SFentryWidth - 2,
				SFlowerY + (i + 1) * SFentryHeight - 1
			);
		}
	}
}

void SFdrawList(n, doScroll)
	int	n;
	int	doScroll;
{
	SFDir	*dir;
	Window	w;

	SFclearList(n, doScroll);

	if (SFdirPtr + n < SFdirEnd) {
		dir = &(SFdirs[SFdirPtr + n]);
		w = XtWindow(selFileLists[n]);
		XDrawImageString(
			SFdisplay,
			w,
			SFtextGC,
			SFtextX - dir->hOrigin * SFcharWidth,
			SFlineToTextV + SFaboveAndBelowText + SFcharAscent,
			dir->dir,
			strlen(dir->dir)
		);
		SFdrawStrings(w, dir, 0, SFlistSize - 1);
	}
}

void SFdrawLists(doScroll)
	int	doScroll;
{
	int	i;

	for (i = 0; i < 3; i++) {
		SFdrawList(i, doScroll);
	}
}

static void
SFinvertEntry(n)
	register int	n;
{
	XFillRectangle(
		SFdisplay,
		XtWindow(selFileLists[n]),
		SFinvertGC,
		SFlineToTextH,
		SFcurrentInvert[n] * SFentryHeight + SFlowerY,
		SFentryWidth,
		SFentryHeight
	);
}

static unsigned long
SFscrollTimerInterval()
{
	static int	maxVal = 200;
	static int	varyDist = 50;
	static int	minDist = 50;
	int		t;
	int		dist;

	if (SFcurrentListY < SFlowerY) {
		dist = SFlowerY - SFcurrentListY;
	} else if (SFcurrentListY > SFupperY) {
		dist = SFcurrentListY - SFupperY;
	} else {
		return (unsigned long) 1;
	}

	t = maxVal - ((maxVal / varyDist) * (dist - minDist));

	if (t < 1) {
		t = 1;
	}

	if (t > maxVal) {
		t = maxVal;
	}

	return (unsigned long) t;
}

static void
SFscrollTimer(p, id)
	XtPointer	p;
        XtIntervalId    *id;
{
	SFDir	*dir;
	int	save;
	int     n;

        n = (int) p;

	dir = &(SFdirs[SFdirPtr + n]);
	save = dir->vOrigin;

	if (SFcurrentListY < SFlowerY) {
		if (dir->vOrigin > 0) {
			SFvSliderMovedCallback(selFileVScrolls[n], n,
				dir->vOrigin - 1);
		}
	} else if (SFcurrentListY > SFupperY) {
		if (dir->vOrigin < dir->nEntries - SFlistSize) {
			SFvSliderMovedCallback(selFileVScrolls[n], n,
				dir->vOrigin + 1);
		}
	}

	if (dir->vOrigin != save) {
		if (dir->nEntries) {
		    XawScrollbarSetThumb(
			selFileVScrolls[n],
			(float) (((double) dir->vOrigin) / dir->nEntries),
			(float) (((double) ((dir->nEntries < SFlistSize) ?
				dir->nEntries : SFlistSize)) / dir->nEntries)
		    );
		}
	}

	if (SFbuttonPressed) {
		SFscrollTimerId = XtAppAddTimeOut(SFapp,
			SFscrollTimerInterval(), SFscrollTimer, (XtPointer) n);
	}
}

static int
SFnewInvertEntry(n, event)
	register int		n;
	register XMotionEvent	*event;
{
	register int	x, y;
	register int	new;
	static int	SFscrollTimerAdded = 0;

	x = event->x;
	y = event->y;

	if (SFdirPtr + n >= SFdirEnd) {
		return -1;
	} else if (
		(x >= 0)	&& (x <= SFupperX) &&
		(y >= SFlowerY)	&& (y <= SFupperY)
	) {
		register SFDir *dir = &(SFdirs[SFdirPtr + n]);

		if (SFscrollTimerAdded) {
			SFscrollTimerAdded = 0;
			XtRemoveTimeOut(SFscrollTimerId);
		}

		new = (y - SFlowerY) / SFentryHeight;
		if (dir->vOrigin + new >= dir->nEntries) {
			return -1;
		}
		return new;
	} else {
		if (SFbuttonPressed) {
			SFcurrentListY = y;
			if (!SFscrollTimerAdded) {
				SFscrollTimerAdded = 1;
				SFscrollTimerId = XtAppAddTimeOut(SFapp,
					SFscrollTimerInterval(), SFscrollTimer,
					(XtPointer) n);
			}
		}

		return -1;
	}
}

/* ARGSUSED */
static void
SFenterList(w, n, event)
	Widget				w;
	register int			n;
	register XEnterWindowEvent	*event;
{
	register int	new;

	/* sanity */
	if (SFcurrentInvert[n] != -1) {
		SFinvertEntry(n);
		SFcurrentInvert[n] = -1;
	}

	new = SFnewInvertEntry(n, (XMotionEvent *) event);
	if (new != -1) {
		SFcurrentInvert[n] = new;
		SFinvertEntry(n);
	}
}

/* ARGSUSED */
static void
SFleaveList(w, n, event)
	Widget		w;
	register int	n;
	XEvent		*event;
{
	if (SFcurrentInvert[n] != -1) {
		SFinvertEntry(n);
		SFcurrentInvert[n] = -1;
	}
}

/* ARGSUSED */
static void
SFmotionList(w, n, event)
	Widget			w;
	register int		n;
	register XMotionEvent	*event;
{
	register int	new;

	new = SFnewInvertEntry(n, event);

	if (new != SFcurrentInvert[n]) {
		if (SFcurrentInvert[n] != -1) {
			SFinvertEntry(n);
		}
		SFcurrentInvert[n] = new;
		if (new != -1) {
			SFinvertEntry(n);
		}
	}
}

/* ARGSUSED */
static void
SFvFloatSliderMovedCallback(w, n, fnew)
	Widget	w;
	int	n;
	float	*fnew;
{
	int	new;

	new = (*fnew) * SFdirs[SFdirPtr + n].nEntries;

	SFvSliderMovedCallback(w, n, new);
}

/* ARGSUSED */
static void
SFvSliderMovedCallback(w, n, new)
	Widget	w;
	int	n;
	int	new;
{
	int		old;
	register Window	win;
	SFDir		*dir;

	dir = &(SFdirs[SFdirPtr + n]);

	old = dir->vOrigin;
	dir->vOrigin = new;

	if (old == new) {
		return;
	}

	win = XtWindow(selFileLists[n]);

	if (ABS(new - old) < SFlistSize) {
		if (new > old) {
			XCopyArea(
				SFdisplay,
				win,
				win,
				SFscrollGC,
				SFlineToTextH,
				SFlowerY + (new - old) * SFentryHeight,
				SFentryWidth + SFlineToTextH,
				(SFlistSize - (new - old)) * SFentryHeight,
				SFlineToTextH,
				SFlowerY
			);
			XClearArea(
				SFdisplay,
				win,
				SFlineToTextH,
				SFlowerY + (SFlistSize - (new - old)) *
					SFentryHeight,
				SFentryWidth + SFlineToTextH,
				(new - old) * SFentryHeight,
				False
			);
			SFdrawStrings(win, dir, SFlistSize - (new - old),
				SFlistSize - 1);
		} else {
			XCopyArea(
				SFdisplay,
				win,
				win,
				SFscrollGC,
				SFlineToTextH,
				SFlowerY,
				SFentryWidth + SFlineToTextH,
				(SFlistSize - (old - new)) * SFentryHeight,
				SFlineToTextH,
				SFlowerY + (old - new) * SFentryHeight
			);
			XClearArea(
				SFdisplay,
				win,
				SFlineToTextH,
				SFlowerY,
				SFentryWidth + SFlineToTextH,
				(old - new) * SFentryHeight,
				False
			);
			SFdrawStrings(win, dir, 0, old - new);
		}
	} else {
		XClearArea(
			SFdisplay,
			win,
			SFlineToTextH,
			SFlowerY,
			SFentryWidth + SFlineToTextH,
			SFlistSize * SFentryHeight,
			False
		);
		SFdrawStrings(win, dir, 0, SFlistSize - 1);
	}
}

/* ARGSUSED */
static void
SFvAreaSelectedCallback(w, n, pnew)
	Widget	w;
	int	n;
	int	pnew;
{
	SFDir	*dir;
	int	new;

	dir = &(SFdirs[SFdirPtr + n]);

	new = dir->vOrigin +
		(((double) pnew) / SFvScrollHeight) * dir->nEntries;

	if (new > dir->nEntries - SFlistSize) {
		new = dir->nEntries - SFlistSize;
	}

	if (new < 0) {
		new = 0;
	}

	if (dir->nEntries) {
		float	f;

		f = ((double) new) / dir->nEntries;

		XawScrollbarSetThumb(
			w,
			f,
			(float) (((double) ((dir->nEntries < SFlistSize) ?
				dir->nEntries : SFlistSize)) / dir->nEntries)
		);
	}

	SFvSliderMovedCallback(w, n, new);
}

/* ARGSUSED */
static void
SFhSliderMovedCallback(w, n, new)
	Widget	w;
	int	n;
	float	*new;
{
	SFDir	*dir;
	int	save;

	dir = &(SFdirs[SFdirPtr + n]);
	save = dir->hOrigin;
	dir->hOrigin = (*new) * dir->nChars;
	if (dir->hOrigin == save) {
		return;
	}

	SFdrawList(n, SF_DO_NOT_SCROLL);
}

/* ARGSUSED */
static void
SFhAreaSelectedCallback(w, n, pnew)
	Widget	w;
	int	n;
	int	pnew;
{
	SFDir	*dir;
	int	new;

	dir = &(SFdirs[SFdirPtr + n]);

	new = dir->hOrigin +
		(((double) pnew) / SFhScrollWidth) * dir->nChars;

	if (new > dir->nChars - SFcharsPerEntry) {
		new = dir->nChars - SFcharsPerEntry;
	}

	if (new < 0) {
		new = 0;
	}

	if (dir->nChars) {
		float	f;

		f = ((double) new) / dir->nChars;

		XawScrollbarSetThumb(
			w,
			f,
			(float) (((double) ((dir->nChars < SFcharsPerEntry) ?
				dir->nChars : SFcharsPerEntry)) / dir->nChars)
		);

		SFhSliderMovedCallback(w, n, &f);
	}
}

/* ARGSUSED */
static void
SFpathSliderMovedCallback(w, client_data, new)
	Widget		w;
	XtPointer	client_data;
	float	*new;
{
	SFDir		*dir;
	int		n;
	XawTextPosition	pos;
	int	SFdirPtrSave;

	SFdirPtrSave = SFdirPtr;
	SFdirPtr = (*new) * SFdirEnd;
	if (SFdirPtr == SFdirPtrSave) {
		return;
	}

	SFdrawLists(SF_DO_SCROLL);

	n = 2;
	while (SFdirPtr + n >= SFdirEnd) {
		n--;
	}

	dir = &(SFdirs[SFdirPtr + n]);

	pos = dir->path - SFcurrentPath;

	if (!strncmp(SFcurrentPath, SFstartDir, strlen(SFstartDir))) {
		pos -= strlen(SFstartDir);
		if (pos < 0) {
			pos = 0;
		}
	}

	XawTextSetInsertionPoint(selFileField, pos);
}

/* ARGSUSED */

static void
SFpathAreaSelectedCallback(w, client_data, pnew)
	Widget		w;
	XtPointer	client_data;
	int		pnew;
{
	int	new;
	float	f;

	new = SFdirPtr + (((double) pnew) / SFpathScrollWidth) * SFdirEnd;

	if (new > SFdirEnd - 3) {
		new = SFdirEnd - 3;
	}

	if (new < 0) {
		new = 0;
	}

	f = ((double) new) / SFdirEnd;

	XawScrollbarSetThumb(
		w,
		f,
		(float) (((double) ((SFdirEnd < 3) ? SFdirEnd : 3)) /
			SFdirEnd)
	);

	SFpathSliderMovedCallback(w, (XtPointer) NULL, &f);
}

static Boolean
SFworkProc()
{
	register SFDir		*dir;
	register SFEntry	*entry;

	for (dir = &(SFdirs[SFdirEnd - 1]); dir >= SFdirs; dir--) {
		if (!(dir->nEntries)) {
			continue;
		}
		for (
			entry = &(dir->entries[dir->nEntries - 1]);
			entry >= dir->entries;
			entry--
		) {
			if (!(entry->statDone)) {
				(void) SFstatAndCheck(dir, entry);
				return False;
			}
		}
	}

	SFworkProcAdded = 0;

	return True;
}


static void
SFfree(i)
	int	i;
{
	register SFDir	*dir;
	register int	j;

	dir = &(SFdirs[i]);

	for (j = dir->nEntries - 1; j >= 0; j--) {
		if (dir->entries[j].shown != dir->entries[j].real) {
			XtFree(dir->entries[j].shown);
		}
		XtFree(dir->entries[j].real);
	}

	XtFree((char *) dir->entries);

	XtFree(dir->dir);

	dir->dir = NULL;
}

static void
SFstrdup(s1, s2)
	char	**s1;
	char	*s2;
{
	*s1 = strcpy(XtMalloc((unsigned) (strlen(s2) + 1)), s2);
}

static void
SFunreadableDir(dir)
	SFDir	*dir;
{
	char	*cannotOpen = "<cannot open> ";

	dir->entries = (SFEntry *) XtMalloc(sizeof(SFEntry));
	dir->entries[0].statDone = 1;
	SFstrdup(&dir->entries[0].real, cannotOpen);
	dir->entries[0].shown = dir->entries[0].real;
	dir->nEntries = 1;
	dir->nChars = strlen(cannotOpen);
}

static void SFtextChanged( void );

static void SFsetText(path)
	char	*path;
{
	XawTextBlock	text;

	text.firstPos = 0;
	text.length = strlen(path);
	text.ptr = path;
	text.format = FMT8BIT;

	XawTextReplace(selFileField, 0, strlen(SFtextBuffer), &text);
	XawTextSetInsertionPoint(selFileField, strlen(SFtextBuffer));
}

static void
SFreplaceText(dir, str)
	SFDir	*dir;
	char	*str;
{
	int	len;

	*(dir->path) = 0;
	len = strlen(str);
	if (str[len - 1] == '/') {
		(void) strcat(SFcurrentPath, str);
	} else {
		(void) strncat(SFcurrentPath, str, len - 1);
	}
	if (strncmp(SFcurrentPath, SFstartDir, strlen(SFstartDir))) {
		SFsetText(SFcurrentPath);
	} else {
		SFsetText(&(SFcurrentPath[strlen(SFstartDir)]));
	}

	SFtextChanged();
}

static void
SFexpand(str)
	char	*str;
{
	int	len;
	int	cmp;
	char	*name, *growing;
	SFDir	*dir;
	SFEntry	*entry, *max;

	len = strlen(str);

	dir = &(SFdirs[SFdirEnd - 1]);

	if (dir->beginSelection == -1) {
		SFstrdup(&str, str);
		SFreplaceText(dir, str);
		XtFree(str);
		return;
	} else if (dir->beginSelection == dir->endSelection) {
		SFreplaceText(dir, dir->entries[dir->beginSelection].shown);
		return;
	}

	max = &(dir->entries[dir->endSelection + 1]);

	name = dir->entries[dir->beginSelection].shown;
	SFstrdup(&growing, name);

	cmp = 0;
	while (!cmp) {
		entry = &(dir->entries[dir->beginSelection]);
		while (entry < max) {
			if ((cmp = strncmp(growing, entry->shown, len))) {
				break;
			}
			entry++;
		}
		len++;
	}

	/*
	 * SFreplaceText() expects filename
	 */
	growing[len - 2] = ' ';

	growing[len - 1] = 0;
	SFreplaceText(dir, growing);
	XtFree(growing);
}

static int
SFfindFile(dir, str)
	SFDir		*dir;
	register char	*str;
{
	register int	i, last, max;
	register char	*name, save;
	SFEntry		*entries;
	int		len;
	int		begin, end;
	int		result;

	len = strlen(str);

	if (str[len - 1] == ' ') {
		SFexpand(str);
		return 1;
	} else if (str[len - 1] == '/') {
		len--;
	}

	max = dir->nEntries;

	entries = dir->entries;

	i = 0;
	while (i < max) {
		name = entries[i].shown;
		last = strlen(name) - 1;
		save = name[last];
		name[last] = 0;

		result = strncmp(str, name, len);

		name[last] = save;
		if (result <= 0) {
			break;
		}
		i++;
	}
	begin = i;
	while (i < max) {
		name = entries[i].shown;
		last = strlen(name) - 1;
		save = name[last];
		name[last] = 0;

		result = strncmp(str, name, len);

		name[last] = save;
		if (result) {
			break;
		}
		i++;
	}
	end = i;

	if (begin != end) {
		if (
			(dir->beginSelection != begin) ||
			(dir->endSelection != end - 1)
		) {
			dir->changed = 1;
			dir->beginSelection = begin;
			if (str[strlen(str) - 1] == '/') {
				dir->endSelection = begin;
			} else {
				dir->endSelection = end - 1;
			}
		}
	} else {
		if (dir->beginSelection != -1) {
			dir->changed = 1;
			dir->beginSelection = -1;
			dir->endSelection = -1;
		}
	}

	if (
		SFdoNotTouchVorigin ||
		((begin > dir->vOrigin) && (end < dir->vOrigin + SFlistSize))
	) {
		SFdoNotTouchVorigin = 0;
		return 0;
	}

	i = begin - 1;
	if (i > max - SFlistSize) {
		i = max - SFlistSize;
	}
	if (i < 0) {
		i = 0;
	}

	if (dir->vOrigin != i) {
		dir->vOrigin = i;
		dir->changed = 1;
	}

	return 0;
}

static void
SFunselect()
{
	SFDir	*dir;

	dir = &(SFdirs[SFdirEnd - 1]);
	if (dir->beginSelection != -1) {
		dir->changed = 1;
	}
	dir->beginSelection = -1;
	dir->endSelection = -1;
}

static int
SFcompareLogins(p, q)
	SFLogin	*p, *q;
{
	return strcmp(p->name, q->name);
}

static void
SFgetHomeDirs()
{
	struct passwd	*pw;
	int		alloc;
	int		i;
	SFEntry		*entries = NULL;
	int		len;
	int		maxChars;

	{
			alloc = 1;
			i = 1;
			entries = (SFEntry *) XtMalloc(sizeof(SFEntry));
			SFlogins = (SFLogin *) XtMalloc(sizeof(SFLogin));
			entries[0].real = XtMalloc(3);
			(void) strcpy(entries[0].real, "~");
			entries[0].shown = entries[0].real;
			entries[0].statDone = 1;
			SFlogins[0].name = "";
			pw = getpwuid((int) getuid());
			SFstrdup(&SFlogins[0].dir, pw ? pw->pw_dir : "/");
			maxChars = 0;
	}

	(void) setpwent();

	while ((pw = getpwent()) && (*(pw->pw_name))) {
			if (i >= alloc) {
				alloc *= 2;
				entries = (SFEntry *) XtRealloc(
					(char *) entries,
					(unsigned) (alloc * sizeof(SFEntry))
				);
				SFlogins = (SFLogin *) XtRealloc(
					(char *) SFlogins,
					(unsigned) (alloc * sizeof(SFLogin))
				);
			}
			len = strlen(pw->pw_name);
			entries[i].real = XtMalloc((unsigned) (len + 3));
			(void) strcat(strcpy(entries[i].real, "~"),
				pw->pw_name);
			entries[i].shown = entries[i].real;
			entries[i].statDone = 1;
			if (len > maxChars) {
				maxChars = len;
			}
			SFstrdup(&SFlogins[i].name, pw->pw_name);
			SFstrdup(&SFlogins[i].dir, pw->pw_dir);
			i++;
	}

	SFhomeDir.dir			= XtMalloc(1)	;
	SFhomeDir.dir[0]		= 0		;
	SFhomeDir.path			= SFcurrentPath	;
	SFhomeDir.entries		= entries	;
	SFhomeDir.nEntries		= i		;
	SFhomeDir.vOrigin		= 0		;	/* :-) */
	SFhomeDir.nChars		= maxChars + 2	;
	SFhomeDir.hOrigin		= 0		;
	SFhomeDir.changed		= 1		;
	SFhomeDir.beginSelection	= -1		;
	SFhomeDir.endSelection		= -1		;

#if defined(SVR4) || defined(SYSV) || defined(USG)
	qsort((char *) entries, (unsigned)i, sizeof(SFEntry), SFcompareEntries);
	qsort((char *) SFlogins, (unsigned)i, sizeof(SFLogin), SFcompareLogins);
#else /* defined(SVR4) || defined(SYSV) || defined(USG) */
	qsort((char *) entries, i, sizeof(SFEntry), SFcompareEntries);
	qsort((char *) SFlogins, i, sizeof(SFLogin), SFcompareLogins);
#endif /* defined(SVR4) || defined(SYSV) || defined(USG) */

	for (i--; i >= 0; i--) {
		(void) strcat(entries[i].real, "/");
	}
}

static int
SFfindHomeDir(begin, end)
	char	*begin, *end;
{
	char	save;
	char	*theRest;
	int	i;

	save = *end;
	*end = 0;

	for (i = SFhomeDir.nEntries - 1; i >= 0; i--) {
		if (!strcmp(SFhomeDir.entries[i].real, begin)) {
			*end = save;
			SFstrdup(&theRest, end);
			(void) strcat(strcat(strcpy(SFcurrentPath,
				SFlogins[i].dir), "/"), theRest);
			XtFree(theRest);
			SFsetText(SFcurrentPath);
			SFtextChanged();
			return 1;
		}
	}

	*end = save;

	return 0;
}

static void SFupdatePath()
{
	static int	alloc;
	static int	wasTwiddle = 0;
	char		*begin, *end;
	int		i, j;
	int		prevChange;
	int		SFdirPtrSave, SFdirEndSave;
	SFDir		*dir;

	if (!SFdirs) {
		SFdirs = (SFDir *) XtMalloc((alloc = 10) * sizeof(SFDir));
		dir = &(SFdirs[0]);
		SFstrdup(&dir->dir, "/");
		(void) SFchdir("/");
		(void) SFgetDir(dir);
		for (j = 1; j < alloc; j++) {
			SFdirs[j].dir = NULL;
		}
		dir->path = SFcurrentPath + 1;
		dir->vOrigin = 0;
		dir->hOrigin = 0;
		dir->changed = 1;
		dir->beginSelection = -1;
		dir->endSelection = -1;
		SFhomeDir.dir = NULL;
	}

	SFdirEndSave = SFdirEnd;
	SFdirEnd = 1;

	SFdirPtrSave = SFdirPtr;
	SFdirPtr = 0;

	begin = NULL;

	if (SFcurrentPath[0] == '~') {
		if (!SFtwiddle) {
			SFtwiddle = 1;
			dir = &(SFdirs[0]);
			SFrootDir = *dir;
			if (!SFhomeDir.dir) {
				SFgetHomeDirs();
			}
			*dir = SFhomeDir;
			dir->changed = 1;
		}
		end = SFcurrentPath;
		SFdoNotTouchDirPtr = 1;
		wasTwiddle = 1;
	} else {
		if (SFtwiddle) {
			SFtwiddle = 0;
			dir = &(SFdirs[0]);
			*dir = SFrootDir;
			dir->changed = 1;
		}
		end = SFcurrentPath + 1;
	}

	i = 0;

	prevChange = 0;

	while (*end) {
		while (*end++ == '/') {
			;
		}
		end--;
		begin = end;
		while ((*end) && (*end++ != '/')) {
			;
		}
		if ((end - SFcurrentPath <= SFtextPos) && (*(end - 1) == '/')) {
			SFdirPtr = i - 1;
			if (SFdirPtr < 0) {
				SFdirPtr = 0;
			}
		}
		if (*begin) {
			if (*(end - 1) == '/') {
				char save = *end;

				if (SFtwiddle) {
					if (SFfindHomeDir(begin, end)) {
						return;
					}
				}
				*end = 0;
				i++;
				SFdirEnd++;
				if (i >= alloc) {
					SFdirs = (SFDir *) XtRealloc(
						(char *) SFdirs,
						(unsigned) ((alloc *= 2) *
							sizeof(SFDir))
					);
					for (j = alloc / 2; j < alloc; j++) {
						SFdirs[j].dir = NULL;
					}
				}
				dir = &(SFdirs[i]);
				if (
					(!(dir->dir)) ||
					prevChange ||
					strcmp(dir->dir, begin)
				) {
					if (dir->dir) {
						SFfree(i);
					}
					prevChange = 1;
					SFstrdup(&dir->dir, begin);
					dir->path = end;
					dir->vOrigin = 0;
					dir->hOrigin = 0;
					dir->changed = 1;
					dir->beginSelection = -1;
					dir->endSelection = -1;
					(void) SFfindFile(dir - 1, begin);
					if (
						SFchdir(SFcurrentPath) ||
						SFgetDir(dir)
					) {
						SFunreadableDir(dir);
						break;
					}
				}
				*end = save;
				if (!save) {
					SFunselect();
				}
			} else {
				if (SFfindFile(&(SFdirs[SFdirEnd-1]), begin)) {
					return;
				}
			}
		} else {
			SFunselect();
		}
	}

	if ((end == SFcurrentPath + 1) && (!SFtwiddle)) {
		SFunselect();
	}

	for (i = SFdirEnd; i < alloc; i++) {
		if (SFdirs[i].dir) {
			SFfree(i);
		}
	}

	if (SFdoNotTouchDirPtr) {
		if (wasTwiddle) {
			wasTwiddle = 0;
			SFdirPtr = SFdirEnd - 2;
			if (SFdirPtr < 0) {
				SFdirPtr = 0;
			}
		} else {
			SFdirPtr = SFdirPtrSave;
		}
		SFdoNotTouchDirPtr = 0;
	}

	if ((SFdirPtr != SFdirPtrSave) || (SFdirEnd != SFdirEndSave)) {
		XawScrollbarSetThumb(
			selFileHScroll,
			(float) (((double) SFdirPtr) / SFdirEnd),
			(float) (((double) ((SFdirEnd < 3) ? SFdirEnd : 3)) /
				SFdirEnd)
		);
	}

	if (SFdirPtr != SFdirPtrSave) {
		SFdrawLists(SF_DO_SCROLL);
	} else {
		for (i = 0; i < 3; i++) {
			if (SFdirPtr + i < SFdirEnd) {
				if (SFdirs[SFdirPtr + i].changed) {
					SFdirs[SFdirPtr + i].changed = 0;
					SFdrawList(i, SF_DO_SCROLL);
				}
			} else {
				SFclearList(i, SF_DO_SCROLL);
			}
		}
	}
}


/* ARGSUSED */
static void
SFbuttonPressList(w, n, event)
	Widget			w;
	int			n;
	XButtonPressedEvent	*event;
{
	SFbuttonPressed = 1;
}

/* ARGSUSED */
static void
SFbuttonReleaseList(w, n, event)
	Widget			w;
	int			n;
	XButtonReleasedEvent	*event;
{
	SFDir	*dir;

	SFbuttonPressed = 0;

	if (SFcurrentInvert[n] != -1) {
		if (n < 2) {
			SFdoNotTouchDirPtr = 1;
		}
		SFdoNotTouchVorigin = 1;
		dir = &(SFdirs[SFdirPtr + n]);
		SFreplaceText(
			dir,
			dir->entries[dir->vOrigin + SFcurrentInvert[n]].shown
		);
		SFmotionList(w, n, event);
	}
}

static int
SFcheckDir(n, dir)
	int		n;
	SFDir		*dir;
{
	struct stat	statBuf;
	int		i;

	if (
		(!stat(".", &statBuf)) &&
		(statBuf.st_mtime != dir->mtime)
	) {

		/*
		 * If the pointer is currently in the window that we are about
		 * to update, we must warp it to prevent the user from
		 * accidentally selecting the wrong file.
		 */
		if (SFcurrentInvert[n] != -1) {
			XWarpPointer(
				SFdisplay,
				None,
				XtWindow(selFileLists[n]),
				0,
				0,
				0,
				0,
				0,
				0
			);
		}

		for (i = dir->nEntries - 1; i >= 0; i--) {
			if (dir->entries[i].shown != dir->entries[i].real) {
				XtFree(dir->entries[i].shown);
			}
			XtFree(dir->entries[i].real);
		}
		XtFree((char *) dir->entries);
		if (SFgetDir(dir)) {
			SFunreadableDir(dir);
		}
		if (dir->vOrigin > dir->nEntries - SFlistSize) {
			dir->vOrigin = dir->nEntries - SFlistSize;
		}
		if (dir->vOrigin < 0) {
			dir->vOrigin = 0;
		}
		if (dir->hOrigin > dir->nChars - SFcharsPerEntry) {
			dir->hOrigin = dir->nChars - SFcharsPerEntry;
		}
		if (dir->hOrigin < 0) {
			dir->hOrigin = 0;
		}
		dir->beginSelection = -1;
		dir->endSelection = -1;
		SFdoNotTouchVorigin = 1;
		if ((dir + 1)->dir) {
			(void) SFfindFile(dir, (dir + 1)->dir);
		} else {
			(void) SFfindFile(dir, dir->path);
		}

		if (!SFworkProcAdded) {
			(void) XtAppAddWorkProc(SFapp, SFworkProc, NULL);
			SFworkProcAdded = 1;
		}

		return 1;
	}

	return 0;
}

static int
SFcheckFiles(dir)
	SFDir	*dir;
{
	int		from, to;
	int		result;
	char		old, new;
	int		i;
	char		*str;
	int		last;
	struct stat	statBuf;

	result = 0;

	from = dir->vOrigin;
	to = dir->vOrigin + SFlistSize;
	if (to > dir->nEntries) {
		to = dir->nEntries;
	}

	for (i = from; i < to; i++) {
		str = dir->entries[i].real;
		last = strlen(str) - 1;
		old = str[last];
		str[last] = 0;
		if (stat(str, &statBuf)) {
			new = ' ';
		} else {
			new = SFstatChar(&statBuf);
		}
		str[last] = new;
		if (new != old) {
			result = 1;
		}
	}

	return result;
}

static void
SFdirModTimer(cl, id)
        XtPointer       cl;
        XtIntervalId    *id;
{
	static int	n = -1;
	static int	f = 0;
	char		save;
	SFDir		*dir;

	if ((!SFtwiddle) && (SFdirPtr < SFdirEnd)) {
		n++;
		if ((n > 2) || (SFdirPtr + n >= SFdirEnd)) {
			n = 0;
			f++;
			if ((f > 2) || (SFdirPtr + f >= SFdirEnd)) {
				f = 0;
			}
		}
		dir = &(SFdirs[SFdirPtr + n]);
		save = *(dir->path);
		*(dir->path) = 0;
		if (SFchdir(SFcurrentPath)) {
			*(dir->path) = save;

			/*
			 * force a re-read
			 */
			*(dir->dir) = 0;

			SFupdatePath();
		} else {
			*(dir->path) = save;
			if (
				SFcheckDir(n, dir) ||
				((f == n) && SFcheckFiles(dir))
			) {
				SFdrawList(n, SF_DO_SCROLL);
			}
		}
	}

	SFdirModTimerId = XtAppAddTimeOut(SFapp, (unsigned long) 1000,
		SFdirModTimer, (XtPointer) NULL);
}

/* Return a single character describing what kind of file STATBUF is.  */

static char
SFstatChar (statBuf)
	struct stat *statBuf;
{
	if (S_ISDIR (statBuf->st_mode)) {
		return '/';
	} else if (S_ISREG (statBuf->st_mode)) {
	  return S_ISXXX (statBuf->st_mode) ? '*' : ' ';
#ifdef S_ISSOCK
	} else if (S_ISSOCK (statBuf->st_mode)) {
		return '=';
#endif /* S_ISSOCK */
	} else {
		return ' ';
	}
}

/* ARGSUSED */
static void
SFexposeList(w, n, event, cont)
	Widget		w;
	XtPointer	n;
        XEvent   	*event;
        Boolean         *cont;
{
	if ((event->type == NoExpose) || event->xexpose.count) {
		return;
	}

	SFdrawList(n, SF_DO_NOT_SCROLL);
}

/* ARGSUSED */
static void
SFmodVerifyCallback(w, client_data, event, cont)
	Widget			w;
	XtPointer		client_data;
        XEvent	                *event;
        Boolean                 *cont;
{
	char	buf[2];

	if (
		(XLookupString(&(event->xkey), buf, 2, NULL, NULL) == 1) &&
		((*buf) == '\r')
	) {
		SFstatus = SEL_FILE_OK;
	} else {
		SFstatus = SEL_FILE_TEXT;
	}
}

/* ARGSUSED */
static void
SFokCallback(w, cl, cd)
	Widget	w;
        XtPointer cl, cd;
{
	SFstatus = SEL_FILE_OK;
}

static XtCallbackRec SFokSelect[] = {
	{ SFokCallback, (XtPointer) NULL },
	{ NULL, (XtPointer) NULL },
};

/* ARGSUSED */
static void
SFcancelCallback(w, cl, cd)
	Widget	w;
        XtPointer cl, cd;
{
	SFstatus = SEL_FILE_CANCEL;
}

static XtCallbackRec SFcancelSelect[] = {
	{ SFcancelCallback, (XtPointer) NULL },
	{ NULL, (XtPointer) NULL },
};

static void
SFhomeCallback(w, cl, cd)
	Widget	w;
        XtPointer cl, cd;
{
SFsetText("~/");
SFtextChanged();
}

static XtCallbackRec SFhomeSelect[] = {
	{ SFhomeCallback, (XtPointer) NULL },
	{ NULL, (XtPointer) NULL },
};

/* ARGSUSED */
static void
SFdismissAction(w, event, params, num_params)
	Widget	w;
	XEvent *event;
	String *params;
	Cardinal *num_params;
{
	if (event->type == ClientMessage &&
	    event->xclient.data.l[0] != SFwmDeleteWindow) return;

	SFstatus = SEL_FILE_CANCEL;
}

static XtActionsRec actions[] = {
	{"SelFileDismiss",	SFdismissAction},
};

/****************************************************************************
**
*F  SFpositionWidget( <w> ) . . . . . . . .  position widget under the cursor
*/
static void SFpositionWidget(w)
    Widget		w;
{
    Dimension 		width, height, b_width;
    Int 		dummyx, dummyy;
    Int 		x, y, max_x, max_y;
    UInt 		dummymask;
    Window 		root, child;
    
    /* find out where the pointer is */
    XQueryPointer( XtDisplay(w), XtWindow(w), &root, &child, &x, &y,
		   &dummyx, &dummyy, &dummymask );

    /* get the dimensions of the widget */
    XtVaGetValues( w, XtNwidth,       &width,
		      XtNheight,      &height,
		      XtNborderWidth, &b_width,
		      NULL );

    /* calculate a nice position */
    width  += 2 * b_width;
    height += 2 * b_width;
    x      -= ( (Position) width/2 );
    y      -= ( (Position) height/2 );

    /* make sure that the widget lies within the screen boundaries */
    if ( x < 0 )
	x = 0;
    if ( x > (max_x = (Position) (XtScreen(w)->width - width)) )
	x = max_x;
    if (y < 0)
	y = 0;
    if ( y > (max_y = (Position) (XtScreen(w)->height - height)) )
	y = max_y;
    
    /* set the x and y position in <w> */
    XtVaSetValues( w, XtNx, x, XtNy, y, NULL );
}


/****************************************************************************
**
*F  SFtextChanged() . . . . . . . . . . . . . . .  path text has been changed
*/
static void SFtextChanged()
{
    if ( (SFtextBuffer[0] == '/') || (SFtextBuffer[0] == '~') )
    {
	(void) strcpy(SFcurrentPath, SFtextBuffer);
	SFtextPos = XawTextGetInsertionPoint(selFileField);
    }
    else
    {
	(void) strcat(strcpy(SFcurrentPath, SFstartDir), SFtextBuffer);
	SFtextPos = XawTextGetInsertionPoint(selFileField)
	          + strlen(SFstartDir);
    }

    if (!SFworkProcAdded) {
	(void) XtAppAddWorkProc(SFapp, SFworkProc, NULL);
	SFworkProcAdded = 1;
    }
    SFupdatePath();
}


/****************************************************************************
**
*F  SFcreateWidgets( <toplevel> ) . . . . . . .  create file selector widgets
*/
static char *wmDeleteWindowTranslation =
    "<Message>WM_PROTOCOLS:	SelFileDismiss()\n";

static void SFcreateWidgets ( toplevel )
    Widget	toplevel;
{
    Int       	n;
    Int		listWidth, listHeight;
    Int		listSpacing = 10;
    Int		scrollThickness = 15;
    Int		hScrollX, hScrollY;
    Int		vScrollX, vScrollY;
    Cursor      xtermCursor;
    Cursor      sbRightArrowCursor;
    Cursor      dotCursor;

    /* create a new toplevel shell */
    selFile = XtVaAppCreateShell(
	          "XGap",                    "FileSelector",
		  transientShellWidgetClass, SFdisplay,
		  XtNtransientFor,           toplevel,
		  NULL );

    /* Add WM_DELETE_WINDOW protocol */
    XtAppAddActions( XtWidgetToApplicationContext(selFile),
		     actions, XtNumber(actions) );
    XtOverrideTranslations( selFile,
        XtParseTranslationTable(wmDeleteWindowTranslation) );

    /* create the file selector components */
    selFileForm = XtVaCreateManagedWidget(
		      "selFileForm", formWidgetClass, selFile,
		      XtNdefaultDistance, 30,
		      NULL);

    selFilePrompt = XtVaCreateManagedWidget(
		      "selFilePrompt", labelWidgetClass, selFileForm,
		      XtNlabel,           "Enter a Filename",
		      XtNresizable,       True,
                      XtNtop,             XtChainTop,
                      XtNbottom,          XtChainTop,
                      XtNleft,            XtChainLeft,
                      XtNright,           XtChainLeft,
                      XtNborderWidth,     0,
                      NULL );
    XtVaGetValues( selFilePrompt,
		      XtNforeground,      &SFfore,
	              XtNbackground,      &SFback,
		      NULL );

    /* initialize fonts */
    SFinitFont();

    /* compute positions */
    SFentryWidth  = 2*SFbesideText + SFcharsPerEntry*SFcharWidth;
    SFentryHeight = 2*SFaboveAndBelowText + SFcharHeight;

    listWidth  = SFlineToTextH + SFentryWidth + SFlineToTextH + 1
                 + scrollThickness;
    listHeight = SFlineToTextV + SFentryHeight + SFlineToTextV + 1
                 + SFlineToTextV + SFlistSize * SFentryHeight
		 + SFlineToTextV + 1 + scrollThickness;

    SFpathScrollWidth = 3 * listWidth + 2 * listSpacing + 4;

    hScrollX = -1;
    hScrollY = SFlineToTextV + SFentryHeight + SFlineToTextV + 1 
	       + SFlineToTextV + SFlistSize * SFentryHeight
	       + SFlineToTextV;
    SFhScrollWidth = SFlineToTextH + SFentryWidth + SFlineToTextH;

    vScrollX = SFlineToTextH + SFentryWidth + SFlineToTextH;
    vScrollY = SFlineToTextV + SFentryHeight + SFlineToTextV;
    SFvScrollHeight = 2*SFlineToTextV + SFlistSize * SFentryHeight;

    SFupperX = SFlineToTextH + SFentryWidth + SFlineToTextH - 1;
    SFlowerY = 2*SFlineToTextV + SFentryHeight + SFlineToTextV + 1;
    SFupperY = SFlineToTextV + SFentryHeight + SFlineToTextV + 1
	       + SFlineToTextV + SFlistSize * SFentryHeight - 1;

    SFtextX = SFlineToTextH + SFbesideText;
    SFtextYoffset = SFlowerY + SFaboveAndBelowText + SFcharAscent;

    SFsegs[0].x1 = 0;
    SFsegs[0].y1 = vScrollY;
    SFsegs[0].x2 = vScrollX - 1;
    SFsegs[0].y2 = vScrollY;
    SFsegs[1].x1 = vScrollX;
    SFsegs[1].y1 = 0;
    SFsegs[1].x2 = vScrollX;
    SFsegs[1].y2 = vScrollY - 1;

    SFcompletionSegs[0].x1 = SFcompletionSegs[0].x2 = SFlineToTextH;
    SFcompletionSegs[1].x1 = SFcompletionSegs[1].x2 =
		SFlineToTextH + SFentryWidth - 1;

    /* create more widgets */
    selFileField = XtVaCreateManagedWidget(
		     "selFileField", asciiTextWidgetClass, selFileForm,
                     XtNwidth,            3*listWidth+2*listSpacing+4,
                     XtNborderColor,      SFfore,
                     XtNfromVert,         selFilePrompt,
                     XtNvertDistance,     10,
                     XtNresizable,        True,
                     XtNtop,              XtChainTop,
                     XtNbottom,           XtChainTop,
                     XtNleft,             XtChainLeft,
                     XtNright,            XtChainLeft,
                     XtNstring,           SFtextBuffer,
                     XtNlength,           MAXPATHLEN,
                     XtNeditType,         XawtextEdit,
                     XtNwrap,             XawtextWrapWord,
                     XtNresize,           XawtextResizeHeight,
                     XtNuseStringInPlace, True,
		     NULL );
    XtOverrideTranslations( selFileField,
        XtParseTranslationTable(oneLineTextEditTranslations) );
    XtSetKeyboardFocus(selFileForm, selFileField);

    selFileHScroll = XtVaCreateManagedWidget(
		     "selFileHScroll", scrollbarWidgetClass, selFileForm,
                     XtNorientation,       XtorientHorizontal,
                     XtNwidth,             SFpathScrollWidth,
                     XtNheight,            scrollThickness,
                     XtNborderColor,       SFfore,
                     XtNfromVert,          selFileField,
                     XtNvertDistance,      30,
                     XtNtop,               XtChainTop,
                     XtNbottom,            XtChainTop,
                     XtNleft,              XtChainLeft,
                     XtNright,             XtChainLeft,
		     NULL );
    XtAddCallback( selFileHScroll, XtNjumpProc,
		   SFpathSliderMovedCallback, (XtPointer) NULL);
    XtAddCallback( selFileHScroll, XtNscrollProc,
		   SFpathAreaSelectedCallback, (XtPointer) NULL);

    selFileLists[0] = XtVaCreateManagedWidget(
		     "selFileList1", compositeWidgetClass, selFileForm,
                     XtNwidth,             listWidth,
                     XtNheight,            listHeight,
                     XtNborderColor,       SFfore,
                     XtNfromVert,          selFileHScroll,
                     XtNvertDistance,      10,
                     XtNtop,               XtChainTop,
                     XtNbottom,            XtChainTop,
                     XtNleft,              XtChainLeft,
                     XtNright,             XtChainLeft,
		     NULL );

    selFileLists[1] = XtVaCreateManagedWidget(
		     "selFileList2", compositeWidgetClass, selFileForm,
                     XtNwidth,             listWidth,
                     XtNheight,            listHeight,
                     XtNborderColor,       SFfore,
                     XtNfromHoriz,         selFileLists[0],
                     XtNfromVert,          selFileHScroll,
                     XtNhorizDistance,     listSpacing,
                     XtNvertDistance,      10,
                     XtNtop,               XtChainTop,
                     XtNbottom,            XtChainTop,
                     XtNleft,              XtChainLeft,
                     XtNright,             XtChainLeft,
		     NULL );
    selFileLists[2] = XtVaCreateManagedWidget(
		     "selFileList3", compositeWidgetClass, selFileForm,
                     XtNwidth,             listWidth,
                     XtNheight,            listHeight,
                     XtNborderColor,       SFfore,
                     XtNfromHoriz,         selFileLists[1],
                     XtNfromVert,          selFileHScroll,
                     XtNhorizDistance,     listSpacing,
                     XtNvertDistance,      10,
                     XtNtop,               XtChainTop,
                     XtNbottom,            XtChainTop,
                     XtNleft,              XtChainLeft,
                     XtNright,             XtChainLeft,
		     NULL );

    for ( n = 0;  n < 3;  n++ )
    {
	selFileVScrolls[n] = XtVaCreateManagedWidget(
		     "selFileVScroll", scrollbarWidgetClass, selFileLists[n],
                     XtNx,                 vScrollX,
                     XtNy,                 vScrollY,
                     XtNwidth,             scrollThickness,
                     XtNheight,            SFvScrollHeight,
                     XtNborderColor,       SFfore,
		     NULL );
	XtAddCallback( selFileVScrolls[n], XtNjumpProc,
		       SFvFloatSliderMovedCallback, (XtPointer) n );
	XtAddCallback( selFileVScrolls[n], XtNscrollProc,
			SFvAreaSelectedCallback, (XtPointer) n );

	selFileHScrolls[n] = XtVaCreateManagedWidget(
		     "selFileHScroll", scrollbarWidgetClass, selFileLists[n],
                     XtNorientation,       XtorientHorizontal,
                     XtNx,                 hScrollX,
                     XtNy,                 hScrollY,
                     XtNwidth,             SFhScrollWidth,
                     XtNheight,            scrollThickness,
                     XtNborderColor,       SFfore,
                     NULL );
	XtAddCallback( selFileHScrolls[n], XtNjumpProc,
		       SFhSliderMovedCallback, (XtPointer) n );
	XtAddCallback( selFileHScrolls[n], XtNscrollProc,
		       SFhAreaSelectedCallback, (XtPointer) n );
    }

    selFileOK = XtVaCreateManagedWidget(
		     "selFileOK", commandWidgetClass, selFileForm, 
                     XtNresizable,         True,
                     XtNcallback,          SFokSelect,
                     XtNborderColor,       SFfore,
                     XtNfromVert,          selFileLists[0],
                     XtNvertDistance,      30,
                     XtNtop,               XtChainTop,
                     XtNbottom,            XtChainTop,
                     XtNleft,              XtChainLeft,
                     XtNright,             XtChainLeft,
                     NULL );
    selFileCancel = XtVaCreateManagedWidget(
		     "selFileCancel", commandWidgetClass, selFileForm,
                     XtNresizable,         True,
                     XtNcallback,          SFcancelSelect,
                     XtNborderColor,       SFfore,
                     XtNfromHoriz,         selFileOK,
                     XtNfromVert,          selFileLists[0],
                     XtNhorizDistance,     30,
                     XtNvertDistance,      30,
                     XtNtop,               XtChainTop,
                     XtNbottom,            XtChainTop,
                     XtNleft,              XtChainLeft,
                     XtNright,             XtChainLeft,
                     NULL );
    selFileHome = XtVaCreateManagedWidget(
		     "selFileHome", commandWidgetClass, selFileForm,
                     XtNresizable,         True,
                     XtNcallback,          SFhomeSelect,
                     XtNborderColor,       SFfore,
                     XtNfromHoriz,         selFileCancel,
                     XtNfromVert,          selFileLists[0],
                     XtNhorizDistance,     30,
                     XtNvertDistance,      30,
                     XtNtop,               XtChainTop,
                     XtNbottom,            XtChainTop,
                     XtNleft,              XtChainLeft,
                     XtNright,             XtChainLeft,
                     NULL );

    /* realise toplevel */
    XtSetMappedWhenManaged( selFile, False );
    XtRealizeWidget(selFile);

    /* Add WM_DELETE_WINDOW protocol */
    SFwmDeleteWindow = XInternAtom( SFdisplay, "WM_DELETE_WINDOW", False );
    XSetWMProtocols( SFdisplay, XtWindow(selFile), &SFwmDeleteWindow, 1 );

    /* create default graphic context */
    SFcreateGC();

    /* create cursors */
    xtermCursor        = XCreateFontCursor( SFdisplay, XC_xterm );
    sbRightArrowCursor = XCreateFontCursor( SFdisplay, XC_sb_right_arrow );
    dotCursor          = XCreateFontCursor( SFdisplay, XC_dot );

    XDefineCursor( SFdisplay, XtWindow(selFileOK),     dotCursor );
    XDefineCursor( SFdisplay, XtWindow(selFileCancel), dotCursor );
    XDefineCursor( SFdisplay, XtWindow(selFileHome),   dotCursor );
    XDefineCursor( SFdisplay, XtWindow(selFileForm),   xtermCursor );
    XDefineCursor( SFdisplay, XtWindow(selFileField),  xtermCursor );
    for (n = 0; n < 3; n++)
	XDefineCursor( SFdisplay, XtWindow(selFileLists[n]), 
                       sbRightArrowCursor);

    /* set event handler */
    for ( n = 0;  n < 3;  n++ )
    {
	XtAddEventHandler( selFileLists[n], ExposureMask, True,
			   SFexposeList, (XtPointer) n );
	XtAddEventHandler( selFileLists[n], EnterWindowMask, False,
			   SFenterList, (XtPointer) n );
	XtAddEventHandler( selFileLists[n], LeaveWindowMask, False,
			   SFleaveList, (XtPointer) n );
	XtAddEventHandler( selFileLists[n], PointerMotionMask, False,
			   SFmotionList, (XtPointer) n );
	XtAddEventHandler( selFileLists[n], ButtonPressMask, False,
			   SFbuttonPressList, (XtPointer) n );
	XtAddEventHandler( selFileLists[n], ButtonReleaseMask, False,
 			   SFbuttonReleaseList, (XtPointer) n );
    }
    XtAddEventHandler( selFileField, KeyPressMask, False,
		       SFmodVerifyCallback, (XtPointer) NULL);
    SFapp = XtWidgetToApplicationContext(selFile);
}


/****************************************************************************
**
*F  SFgetText() . . . . . . . . . . . . . . . . . . . . . copy user selection
*/
static String SFgetText ()
{
    return strcpy( XtMalloc((strlen(SFtextBuffer)+1)), SFtextBuffer );
}


/****************************************************************************
**
*F  SFprepareToReturn() . . . . . . . . . .  remove grab, unmap file selector
*/
static void SFprepareToReturn ()
{
    SFstatus = SEL_FILE_NULL;
    XtRemoveGrab(selFile);
    XtUnmapWidget(selFile);
    XtRemoveTimeOut(SFdirModTimerId);
    if ( SFchdir(SFstartDir) )
	XtAppWarning(SFapp,"XsraSelFile: can't return to current directory");
}


/****************************************************************************
**
*F  XsraSelFile( <top>, <prompt>, <path>, <show>, <name> )  . . file selector
*/
Boolean XsraSelFile ( toplevel, prompt, init_path, show_entry, name_return )
    Widget		toplevel;
    String		prompt;
    String		init_path;
    Int			(*show_entry)( String, String*, struct stat* );
    String *		name_return;
{
    XEvent		event;

    /* set nice prompt */
    if ( !prompt || !prompt[0] )
	prompt = "Enter Filename";

    /* initialize widgets */
    if ( !SFdisplay )
    {
	SFdisplay = XtDisplay(toplevel);
	SFcreateWidgets(toplevel);
    }
    XtVaSetValues( selFilePrompt, XtNlabel, prompt, NULL );

    /* position widget under cursor */
    SFpositionWidget(selFile);
    XtMapWidget(selFile);

    /* get current directory */
#   if defined(SVR4) || defined(SYSV) || defined(USG) || defined(__GLIBC__)
	if ( !getcwd(SFstartDir, MAXPATHLEN) ) {
	    *SFstartDir = 0;
	    XtAppWarning( SFapp, "XsraSelFile: can't get current directory" );
        }
#   else
	if ( !getwd(SFstartDir) ) {
	    *SFstartDir = 0;
	    XtAppWarning( SFapp, "XsraSelFile: can't get current directory" );
        }
#   endif
    (void) strcat(SFstartDir, "/");
    (void) strcpy(SFcurrentDir, SFstartDir);

    /* set init path */
    if (init_path)
    {
	if (init_path[0] == '/')
	{
	    strcpy(SFcurrentPath, init_path);
	    if ( strncmp( SFcurrentPath, SFstartDir, strlen(SFstartDir) ))
		SFsetText(SFcurrentPath);
	    else
		SFsetText(&(SFcurrentPath[strlen(SFstartDir)]));
	}
	else
	{
	    strcat( strcpy( SFcurrentPath, SFstartDir ), init_path );
	    SFsetText(&(SFcurrentPath[strlen(SFstartDir)]));
	}
    }
    else 
	(void) strcpy(SFcurrentPath, SFstartDir);

    /* function to filter entries */
    SFfunc = show_entry;

    /* force redisplay */
    SFtextChanged();

    /* grab input for modal widget */
    XtAddGrab(selFile, True, True);

    /* set time out function */
    SFdirModTimerId = XtAppAddTimeOut( SFapp, (unsigned long) 1000,
      		                       SFdirModTimer, (XtPointer) 0 );

    /* loop until user selects OK or CANCEL */
    while (1)
    {
	XtAppNextEvent( SFapp, &event );
	XtDispatchEvent(&event);
	switch (SFstatus)
	{
	    case SEL_FILE_TEXT:
	        SFstatus = SEL_FILE_NULL;
		SFtextChanged();
		break;
	    case SEL_FILE_OK:
		*name_return = SFgetText();
		SFprepareToReturn();
		return True;
	    case SEL_FILE_CANCEL:
		SFprepareToReturn();
		return False;
	    case SEL_FILE_NULL:
		break;
	    }
    }
}

#endif


/****************************************************************************
**

*E  selfile.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
