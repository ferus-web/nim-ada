import pkg/ada

var url = parseURL("https://github.com/xyz?x=y")
echo url.hostname
echo url.pathname
echo url.query

var y = url
echo y.hostname

assert url == y
