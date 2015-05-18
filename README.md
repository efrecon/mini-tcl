# mini-tcl
An Alpine Linux based mini Tcl for Docker.

This contains a restricted set of packages necessary for running Tcl 8.6
applications. It is based on an installation of the packages available in Alpine
Linux, and an install of the latest tcllib. That should leave you with tls,
expect, all the Tcl 8.6 packages (threads, database connections, etc.) and the
whole of the tcllib.  The [pure-tcl readline](http://wiki.tcl.tk/20215) is
enabled by default for the root user in the container so you will have a decent
prompt at the command line.

## Building and Running

To build, simply write:

    docker build -t efrecon/mini-tcl .

To run and get an interactive Tcl prompt:

    docker run -it --rm efrecon/mini-tcl

## Running your own scripts

This image exports `/opt/tcl` as a volume and arranges to give that
directory and its sub-directory `lib` as additional locations when
looking for packages.  This means that you should be able to mount
local directories onto `/opt/tcl` to run your own code within the
container.

Additionally, the image exports `/opt/data` to place random data that
you might wish to access from within the container.
