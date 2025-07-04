import std/[options, unittest]
import pkg/ada

suite "basic url parsing tests":
  test "parse basic URL":
    let url = parseURL("https://github.com/ferus-web/nim-ada")

    check(url.hostname == "github.com")
    check(url.pathname == "/ferus-web/nim-ada")
    check(url.port.isNone)
    check(url.query.isNone)
    check(url.scheme == "https:")
    check(url.username.isNone)
    check(url.password.isNone)

  test "URL with port":
    let url = parseURL("https://github.com:8090")

    check(url.port.isSome and url.port.get() == 8090)
