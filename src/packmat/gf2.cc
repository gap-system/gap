/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Kernels of the kind GF2: one bit per cell, 64 cells per word.
*/

#include "kernels.h"

namespace packmat {

const Kernels gf2_kernels = cell_kernels<1>();

}    // namespace packmat
