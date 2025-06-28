# nim-ada
This library provides low-level bindings and a high-level wrapper over [ada-url](https://github.com/ada-url/ada), a high-performance and WHATWG-compliant URL parser written in C++. \
The high-level wrapper manages memory for you via ORC move semantics.

## examples
### parsing a URL
```nim
import std/options
import pkg/ada

var url = parseURL("https://example.com/path?x=y")
echo url.hostname      ## example.com/path?x=y
echo url.pathname      ## /path?x=y
echo url.query.get()   ## ?x=y
```

### validating a URL
```nim
import pkg/ada

let
  urls = [
    "https://github.com",
    "https://lk.m.e,3.,ao????2.s.",     #  <--- These are technically valid URLs,
    "mxl:://///dmnems.xyie",            #  <--- as the WhatWG URL spec is very forgiving for erroneous inputs.
    "https://google.com",
    "....",                             #  <--- However, these two are not. 
    ";:@;3!..//1@#;21"                  #  <---
  ]

for url in urls:
  echo '[' & url & "]: " & (
    if isValidURL(url):
      "valid"
    else:
      "invalid"
  )
```
