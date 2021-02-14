# CGPOP
Miniapp of the conjugate gradient solver from LANL's Parallel Ocean Program

# About this project

The Parallel Ocean Program (POP), developed at Los Alamos National Laboratory, is an important multi-agency code used for global ocean modeling and is a component within the Community Earth System Model (CESM). The motivation for creating a miniapp for the POP developer team is that it will enable them to ensure the performance portability of the most critical portion of the application while also testing new programming models. The CGPOP miniapp is the conjugate gradient solver from LANL POP 2.0, which is the performance bottleneck for the full POP application. The CGPOP miniapp is written in Fortran90 with MPI and is about 3000 source lines of code (SLOC), whereas the POP application is 71,000 SLOC.

The best resources to learn about the MiniApp is the following [technical report](http://astonewebsite.s3-website-us-west-2.amazonaws.com/works/cgpop-v1.0-tech-report.pdf) or [conference paper](http://astonewebsite.s3-website-us-west-2.amazonaws.com/works/ppopp.pdf).

This repository includes a few different implementations of CGPOP.  These are:
* caf1D --- Co-Array Fortran version using 1D data structure for communication.
* caf1D_sync_iamges --- Co-Array Fortran version using 1D data structure for communication.  This version overlaps computation and  communication.
* caf2D --- Co-Array Fortran version using 2D data structure for communication.
* mpi1s1D --- MPI version using 1-sided (put/get) communication and 1D data structure.
* mpi2s1D_overlap --- MPI version using 1-sided (put/get) communication and 1D data structure.  This version overlaps computation and communication.
* mpi2s1D --- MPI version using 2-sided (send/recv) communication and 1D data structure.
* mpi2s2D --- MPI version using 2-sided (send/recv) communication and 2D data structure.
