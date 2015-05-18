FROM alpine
MAINTAINER Emmanuel Frecon <efrecon@gmail.com>

# Install TCL from the main repo
RUN apk add --update tcl expect
# Install TLS from the testing repository, this will move soon
RUN apk add tls --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

# Now copy all nice scripts from our subdirectory to the root
COPY scripts/ /scripts/

# And run a script to get the tcllib from github. wget does not handle https
# on top of busybox, and installing curl would be rather dumb as we can already
# support http and https (as from the installed packages above)
RUN /scripts/wsget.tcl https://github.com/tcltk/tcllib/archive/tcllib_1_17.tar.gz /tmp/

# untar into the temporary directory and install the tcllib to /usr/lib
# so scripts can find it.
RUN tar -zx -C /tmp -f /tmp/tcllib_1_17.tar.gz
RUN tclsh /tmp/tcllib-tcllib_1_17/installer.tcl -no-html -no-nroff -no-examples -no-gui -no-apps -no-wait -pkg-path /usr/lib/tcllib1.17

# Cleanup
RUN rm -rf /var/cache/apk/*
RUN rm -rf /tmp/tcllib*

# Export two volumes, one for tcl code and one for data, just in case.
VOLUME /opt/tcl
VOLUME /opt/data

# Make sure code put into the special tcl volume can lazily be filled
# with packages
ENV TCLLIBPATH /opt/tcl /opt/tcl/lib

# Arrange for a nice prompt
COPY scripts/tclshrc /root/.tclshrc
ENTRYPOINT ["tclsh8.6"]
