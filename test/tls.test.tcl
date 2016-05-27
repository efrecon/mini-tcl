# Maintainer Derk Muenchhausen <derk@muenchhausen.de>

package require tcltest
package require tls
package require http
namespace import -force ::tcltest::*

test https_request_shall_return_HTTP_OK {} -body {

	::http::register https 443 [list ::tls::socket -request 1 -ssl2 0 -ssl3 0 -tls1 1]
	set token [::http::geturl https://github.com]
	set status [::http::status $token]
	::http::cleanup $token
	return $status

} -result "ok"

array set testResult [array get ::tcltest::numTests]
cleanupTests

exit $testResult(Failed)
