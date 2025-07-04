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
    check(url.schemeType == SchemeType.HTTPS)

  test "URL with port":
    let url = parseURL("https://github.com:8090")

    check(url.port.isSome and url.port.get() == 8090)
    check(url.schemeType == SchemeType.HTTPS)

  test "misc":
    let
      a = parseURL("http://something.lol/info#about-me")
      b = parseURL("wss://supersecurechat.xyz")
      c = parseURL("file:///home/buddy/Documents/Savings.xlsx")

    check(a.schemeType == SchemeType.HTTP)
    check(b.schemeType == SchemeType.WSS)
    check(c.schemeType == SchemeType.File)

    check(a.fragment.get() == "#about-me")

    check(a != b)
    check(b != c)
    check(a == a)
    check(b == b)
    check(c == c)

    check(c.pathname == "/home/buddy/Documents/Savings.xlsx")
