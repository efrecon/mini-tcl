#! /usr/bin/env tclsh

package require Tcl
package require tls
package require http

if { [llength $argv] == 0 } {
    puts stderr "Need at least a URL"
}

# The missing procedure of the http package
proc ::http::geturl_followRedirects {url args} {
    while {1} {
        set token [eval [list http::geturl $url] $args]
        switch -glob -- [http::ncode $token] {
            30[1237] {
                if {[catch {array set OPTS $args}]==0} {
                    if { [info exists OPTS(-channel)] } {
                        seek $OPTS(-channel) 0 start
                    }
                }
            }
            default  { return $token }
        }
        upvar #0 $token state
        array set meta [set ${token}(meta)]
        if {![info exist meta(Location)]} {
            return $token
        }
        set url $meta(Location)
        unset meta
    }
}

# Arrange for https to work properly
::http::register https 443 [list ::tls::socket -tls1 1]

set url [lindex $argv 0]
set dstdir .
if { [llength $argv] > 1 } {
    set dstdir [lindex $argv 1]
}

set URLmatcher {(?x)		# this is _expanded_ syntax
	^
	(?: (\w+) : ) ?			# <protocol scheme>
	(?: //
	    (?:
		(
		    [^@/\#?]+		# <userinfo part of authority>
		) @
	    )?
	    (				# <host part of authority>
		[^/:\#?]+ |		# host name or IPv4 address
		\[ [^/\#?]+ \]		# IPv6 address in square brackets
	    )
	    (?: : (\d+) )?		# <port part of authority>
	)?
	( [/\?] [^\#]*)?		# <path> (including query)
	(?: \# (.*) )?			# <fragment>
	$
}

if { [regexp -- $URLmatcher $url -> proto user host port srvurl]} {
    set pathRE {(?xi)
    	    ^
    	    # Path part (already must start with / character)
    	    (?:	      [-\w.~!$&'()*+,;=:@/]  | %[0-9a-f][0-9a-f] )*
    	    # Query part (optional, permits ? characters)
    	    (?: \? (?: [-\w.~!$&'()*+,;=:@/?] | %[0-9a-f][0-9a-f] )* )?
    	    $
    }
    if {[regexp -- $pathRE $srvurl path qry]} {
        set fname [file tail $path]
        set dst_fname [file join $dstdir $fname]
        puts stdout "$url -> $dst_fname"
        if { [catch {open $dst_fname w} fd] == 0 } {
            ::http::geturl_followRedirects $url \
                -channel $fd \
                -binary on
            close $fd
        } else {
            puts stderr "Cannot save to $dst_fname: $fd"
        }
    } else {
        puts stderr "Cannot extract path from $url"
    }
} else {
    puts stderr "Cannot understand $url as a URL!"
}
