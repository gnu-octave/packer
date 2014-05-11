packer
======

new package tool for gnu octave


    octave:1> packer init
    octave:2> packer search instrument-control
    sf.net/instrument-control 0.2.0
        Low level I/O functions for serial, i2c, parallel, tcp, gpib, vxi11 and usbtmc interfaces.
    github/instrument-control 0.2.1
        Low level I/O functions for serial, i2c, parallel, tcp, gpib, vxi11 and usbtmc interfaces.
    octave:3> packer search xlsread
    sf.net/io 2.2.1: has function xlsread
    octave:4> packer info optim
    optim    sf.net          1.3.0   GFDL, GPLv3+, mo         octave (>= 3.4.0), miscellaneous (>= 1.0.10), struct (>= 1.0.10), parallel (>= 2.0.5)
    octave:5> packer install optim # dummy, not working yet
    Installing general
    Installing parallel
    Installing struct
    Installing miscellaneous
    Installing optim
    octave:6> packer init
    packer.db already exist. Do you realy want to reset it? y/n [n]: 
    octave:7> packer update # update database
    octave:8> 