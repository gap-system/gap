#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

ReadLib("distributed/globalobject.gd");
ReadLib("distributed/loutils.g");
ReadLib("distributed/locomm.g");
ReadLib("distributed/hicomm.g");
ReadLib("distributed/collective.g");
ReadLib("distributed/dist_tasks.g");
ReadLib("distributed/globalobject.gi");
ReadLib("distributed/work_stealing.g");
ReadLib("distributed/messageman.g");

MakeReadWriteGVar("MessageManager");
MessageManager := CreateThread(MessageManagerFunc);
MakeReadOnlyGVar("MessageManager");
