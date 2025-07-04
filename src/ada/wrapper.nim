## High-level wrapper over ada-url
## Copyright (C) 2025 Trayambak Rai
import std/[options, strutils, hashes]
import pkg/ada/bindings

type
  URLParseError* = object of ValueError

  URL* = object
    handle: ada_url

# Convenience functions
func optionify(str: string): Option[string] {.inline.} =
  if str.len > 0:
    return some(str)

proc `$`*(str: ada_string): string {.raises: [].} =
  ## Turn an `ada_string` into a string.
  ## This handles the sentinel value properly.
  var buffer = newString(str.length)

  when defined(release):
    copyMem(buffer[0].addr, str.data[0].addr, str.length)
  else:
    for i in 0 ..< str.length:
      buffer[i] = str.data[i]

  move(buffer)

# Move semantic stuff
proc `=destroy`*(url: URL) =
  ada_free(url.handle)

proc `=copy`*(dest: var URL, source: URL) =
  dest.handle = ada_copy(source.handle)

proc `=sink`*(dest: var URL, source: URL) {.error.}

# URL instantiation functions
func getHandle*(url: URL): ada_url {.inline.} =
  ## Get the low-level handle to the URL object.
  ## Use this with precaution.
  ##
  ## It's best you don't store this handle anywhere; its contents will be freed
  ## as soon as this `URL` object goes out of scope.
  url.handle

proc parseURL*(str: string): URL {.raises: [URLParseError], inline.} =
  var handle = ada_parse(str.cstring, str.len.uint64)
  if handle == nil:
    raise newException(URLParseError, "Failed to parse URL: `" & str & '`')

  URL(handle: move(handle))

proc maybeParseURL*(str: string): Option[URL] {.raises: [], inline.} =
  var handle = ada_parse(str.cstring, str.len.uint64)
  if handle == nil:
    return none(URL)

  some(URL(handle: move(handle)))

proc isValidURL*(str: string): bool {.raises: [], inline.} =
  ada_can_parse(str.cstring, str.len.uint64)

# Getter functions
{.push inline, raises: [].}
proc origin*(url: URL): string =
  $ada_get_origin(url.handle)

proc href*(url: URL): string =
  $ada_get_href(url.handle)

proc username*(url: URL): Option[string] =
  optionify($ada_get_username(url.handle))

proc password*(url: URL): Option[string] =
  optionify($ada_get_password(url.handle))

proc port*(url: URL): Option[uint] =
  try:
    some(parseUint($ada_get_port(url.handle)))
  except ValueError:
    none(uint)

proc portString*(url: URL): Option[string] =
  optionify($ada_get_port(url.handle))

proc fragment*(url: URL): Option[string] =
  optionify($ada_get_hash(url.handle))

proc host*(url: URL): Option[string] =
  optionify($ada_get_host(url.handle))

proc hostname*(url: URL): string =
  $ada_get_hostname(url.handle)

proc pathname*(url: URL): string =
  $ada_get_pathname(url.handle)

proc query*(url: URL): Option[string] =
  optionify($ada_get_search(url.handle))

proc search*(url: URL): Option[string] =
  optionify($ada_get_search(url.handle))

proc protocol*(url: URL): string =
  $ada_get_protocol(url.handle)

proc scheme*(url: URL): string =
  $ada_get_protocol(url.handle)

proc hostType*(url: URL): uint8 =
  ada_get_host_type(url.handle)

proc schemeType*(url: URL): uint8 =
  ada_get_scheme_type(url.handle)

proc isValid*(url: URL): bool =
  ada_is_valid(url.handle)

# Setter functions
proc `href=`*(url: var URL, href: string) =
  assert(ada_set_href(url.handle, href.cstring, href.len.uint64))

proc `host=`*(url: var URL, host: string) =
  assert(ada_set_host(url.handle, host.cstring, host.len.uint64))

proc `hostname=`*(url: var URL, hostname: string) =
  assert(ada_set_hostname(url.handle, hostname.cstring, hostname.len.uint64))

proc `protocol=`*(url: var URL, protocol: string) =
  assert(ada_set_protocol(url.handle, protocol.cstring, protocol.len.uint64))

proc `scheme=`*(url: var URL, scheme: string) =
  assert(ada_set_protocol(url.handle, scheme.cstring, scheme.len.uint64))

proc `username=`*(url: var URL, username: string) =
  assert(ada_set_username(url.handle, username.cstring, username.len.uint64))

proc `password=`*(url: var URL, password: string) =
  assert(ada_set_password(url.handle, password.cstring, password.len.uint64))

proc `port=`*(url: var URL, port: SomeInteger | string) =
  let port = $port
  assert(ada_set_port(url.handle, port.cstring, port.len.uint64))

proc `pathname=`*(url: var URL, path: string) =
  assert(ada_set_pathname(url.handle, path.cstring, path.len.uint64))

proc `search=`*(url: var URL, search: string) =
  assert(ada_set_search(url.handle, search.cstring, search.len.uint64))

proc `query=`*(url: var URL, query: string) =
  assert(ada_set_search(url.handle, query.cstring, query.len.uint64))

proc `fragment=`*(url: var URL, frag: string) =
  assert(ada_set_hash(url.handle, frag.cstring, frag.len.uint64))

proc copy*(url: var URL): URL =
  URL(handle: ada_copy(url.handle))

{.pop.}

# Integration functions
proc hash*(url: URL): Hash =
  hash(url.href) !& hash(url.host) !& hash(url.hostname) !& hash(url.protocol) !&
    hash(url.username) !& hash(url.password) !& hash(url.port) !& hash(url.pathname) !&
    hash(url.search) !& hash(url.query)

proc `==`*(a, b: URL): bool {.inline.} =
  hash(a) == hash(b)

proc `!=`*(a, b: URL): bool {.inline.} =
  not (a == b)
