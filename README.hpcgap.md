# HPC-GAP

GAP includes experimental code to support multithreaded programming in GAP,
dubbed HPC-GAP (where HPC stands for "high performance computing"). GAP and
HPC-GAP codebases diverged during the project, and we are currently working
on unifying the codebases and incorporating the HPC-GAP code back into the
mainstream GAP versions.

This is work in progress, and HPC-GAP as it is included with GAP right now
still suffers from various limitations and problems, which we are actively
working on to resolve. However, including it with GAP (disabled by default)
considerably simplifies development of HPC-GAP. It also means that you can
very easily get a (rough!) sneak peak of HPC-GAP. It comes together with the
new manual book called "HPC-GAP Reference Manual" and located in the `doc/hpc`
directory.

Users interested in experimenting with shared memory parallel programming in
GAP can build HPC-GAP by following the instructions from
https://github.com/gap-system/gap/wiki/Building-HPC-GAP. While it is possible
to build HPC-GAP from a release version of GAP you downloaded from the GAP
website, due to the ongoing development of HPC-GAP, we recommend that you
instead build HPC-GAP from the latest development version available in the
GAP repository at GitHub, i.e. https://github.com/gap-system/gap.
