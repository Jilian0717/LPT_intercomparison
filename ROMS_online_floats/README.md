***Running ROMS online floats***

**cpp flag:** 

    #define FLOATS
    #define FLOAT_OYSTER
    #define FLOAT_STICKY: Define for floats to stick/reflect when hitting the bottom or surface 
    #define FLOAT_VWALK: define if floats do vertical random walk
    #define VWALK_FORWARD: define for forward time stepping of vertical random walk

**Input files:**

liveocean.in 

    line 256:  NFLT (Number of timesteps between the writing of data into floats file)    
    line 1076: FLTNAME; # directory of float output    
    line 1082: FPOSNAM;  # directory of float.in
float.in

-------
After compiling roms with floats-related cpp flags, you will see some associated fortran codes in /Build_roms/:

    biology_floats.f90
    def_floats.f90
    interp_floats.f90
    mod_floats.f90
    step_floats.f90: 4th order Milne time-stepping scheme and 4th Hamming corrector
    vwalk_floats.f90: random walk (or random displacement with corrected diffusion?)
    wrt_floats.f90: write output
    read_fltpar.f90

Some useful posts on ROMS forum:

https://www.myroms.org/wiki/floats.in

https://www.myroms.org/forum/viewtopic.php?p=22734&hilit=floats#p22734

Examples in ROMS source codes:

    /ROMS/Include/flt_test.h
    /ROMS/External/roms_flt_test3d.in; floats_flt_test3d.in
