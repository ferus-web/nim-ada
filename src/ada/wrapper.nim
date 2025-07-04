## ============
## Ada URL
## ============
##
## Ada is a fast and spec-compliant URL parser written in C++.
##
## * It's widely tested by both Web Platform Tests and Google OSS Fuzzer.
## * It is extremely fast.
## * It's the default URL parser of Node.js since Node 18.16.0.
## * It supports the Unicode Technical Standard.
##
## The Ada library passes the full range of tests from the specification, across a wide range of platforms (e.g., Windows, Linux, macOS).
## 
## You can read the WHATWG URL specification 
## `here <https://url.spec.whatwg.org/>`_
import std/[options, strutils, hashes]
import pkg/ada/bindings

type
  URLParseError* = object of ValueError
    ## This exception is raised by `parseURL` when the specified input
    ## cannot be parsed into a meaningful URL.

  URL* = object
    ## The URL object.
    ##
    ## Internally, this holds a handle to a `ada_url` (or `void *`), but you needn't worry about that.
    ## If you wish to obtain the aforementioned low-level handle, use the `func getHandle(URL)`_ function.
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
  ## **Note**: It's best you don't store this handle anywhere; its contents will be freed
  ## as soon as this `URL` object goes out of scope.
  url.handle

proc parseURL*(str: string): URL {.raises: [URLParseError], inline.} =
  ## This function parses a string into a URL. Upon failure, it raises the `URLParseError`.
  ##
  ## **Also See**:
  ## * `proc maybeParseURL(string)`_ for a function which returns an `Option[URL]` instead of using exceptions.
  var handle = ada_parse(str.cstring, str.len.uint64)
  if handle == nil:
    raise newException(URLParseError, "Failed to parse URL: `" & str & '`')

  URL(handle: move(handle))

proc maybeParseURL*(str: string): Option[URL] {.raises: [], inline.} =
  ## This function parses a string into a URL. If successful, it returns an `Option[URL]` with the
  ## parsed URL object. Upon failure, it returns an empty `Option[URL]`.
  ##
  ## **See More**:
  ## * `proc parseURL(string)`_ for a function which uses exceptions instead of optionals.
  var handle = ada_parse(str.cstring, str.len.uint64)
  if handle == nil:
    return none(URL)

  some(URL(handle: move(handle)))

proc isValidURL*(str: string): bool {.raises: [], inline.} =
  ## This function takes in a string and determine whether it is a valid,
  ## intelligible URL. If so, it will return `true`. Otherwise, it'll return `false`.
  ##
  ## Keep in mind that this function will return `true` in cases that the programmer
  ## might see as odd. You need to keep in mind that the WHATWG URL specification is
  ## very forgiving, and as such, many odd-looking cases will pass with no issues.
  ##
  ## You are advised to read the WHATWG URL specification to learn more:
  ## `WHATWG URL specification <https://url.spec.whatwg.org/>`_
  ada_can_parse(str.cstring, str.len.uint64)

# Getter functions
{.push inline, raises: [].}
proc origin*(url: URL): string =
  ## Return the origin of this URL.
  ## 
  ## For more details, read 
  ## `the WHATWG URL specification <https://url.spec.whatwg.org/#dom-url-origin>`_
  $ada_get_origin(url.handle)

proc href*(url: URL): string =
  ## Return the parsed version of the URL with all its components.
  ##
  ## For more details, read
  ## `the WHATWG URL specification <https://url.spec.whatwg.org/#dom-url-href>`_
  $ada_get_href(url.handle)

proc username*(url: URL): Option[string] =
  ## Return the username for this URL.
  ##
  ## For more details, read 
  ## `the WHATWG URL specification <https://url.spec.whatwg.org/#dom-url-username>`_
  optionify($ada_get_username(url.handle))

proc password*(url: URL): Option[string] =
  ## Return the username for this URL.
  ##
  ## For more details, read 
  ## `the WHATWG URL specification <https://url.spec.whatwg.org/#dom-url-password>`_
  optionify($ada_get_password(url.handle))

proc port*(url: URL): Option[uint] =
  ## Return the port number for this URL, if specified and parseable into an unsigned integer.
  ##
  ## For more details, read 
  ## `the WHATWG URL specification <https://url.spec.whatwg.org/#concept-url-port>`_
  try:
    some(parseUint($ada_get_port(url.handle)))
  except ValueError:
    none(uint)

proc portString*(url: URL): Option[string] =
  ## Return the port number for this URL, if specified.
  ##
  ## For more details, read 
  ## `the WHATWG URL specification <https://url.spec.whatwg.org/#concept-url-port>`_
  optionify($ada_get_port(url.handle))

proc fragment*(url: URL): Option[string] =
  ## Return the fragment identifier of this URL, if it is non-empty.
  ## A fragment is also called a "hash", as it is the part of the URL which begins with the # symbol.
  ## It is an optional segment of the URL. If it exists, it generally points to a sub-resource within the document,
  ## generally a section heading of a document.
  ##
  ## For more details, read 
  ## `the WHATWG URL specification <https://url.spec.whatwg.org/#dom-url-hash>`_
  optionify($ada_get_hash(url.handle))

proc host*(url: URL): Option[string] =
  ## Return the parsed representation of the host for this URL with an optional port number.
  ##
  ## For more details, read 
  ## `the WHATWG URL specification <https://url.spec.whatwg.org/#dom-url-host>`_
  optionify($ada_get_host(url.handle))

proc hostname*(url: URL): string =
  ## Return the parsed representation of the host for this URL. Non-ASCII domain labels are
  ## punycode-encoded per IDNA if this is the host of a special URL, or percent-encoded for
  ## non-special URLs. The hostname is devoid of a port number.
  ## 
  ## For more details, read 
  ## `the WHATWG URL specification <https://url.spec.whatwg.org/#dom-url-hostname>`_
  $ada_get_hostname(url.handle)

proc pathname*(url: URL): string =
  ## Return the path for this URL.
  ##
  ## For more details, read 
  ## `the WHATWG URL specification <https://url.spec.whatwg.org/#dom-url-pathname>`_
  $ada_get_pathname(url.handle)

proc query*(url: URL): Option[string] =
  ## Return the URL's query string, if it exists.
  ##
  ## For more details, read 
  ## `the WHATWG URL specification <https://url.spec.whatwg.org/#dom-url-search>`_
  ##
  ## **Also See**:
  ## * `proc search(URL)`_ which has the same behaviour as this function.
  optionify($ada_get_search(url.handle))

proc search*(url: URL): Option[string] =
  ## Return the URL's query string, if it exists.
  ##
  ## For more details, read 
  ## `the WHATWG URL specification <https://url.spec.whatwg.org/#dom-url-search>`_
  ##
  ## **Also See**:
  ## * `proc query(URL)`_ which has the same behaviour as this function.
  optionify($ada_get_search(url.handle))

proc protocol*(url: URL): string =
  ## Return the URL's scheme, lower-cased and suffixed with the ':' delimiter.
  ##
  ## For more details, read 
  ## **`the WHATWG URL specification <https://url.spec.whatwg.org/#dom-url-protocol>`_**
  ##
  ## **Also See**:
  ## * `proc scheme(URL)`_ which has the same behaviour as this function.
  $ada_get_protocol(url.handle)

proc scheme*(url: URL): string =
  ## Return the URL's scheme, lower-cased and suffixed with the ':' delimiter.
  ##
  ## For more details, read 
  ## **`the WHATWG URL specification <https://url.spec.whatwg.org/#dom-url-protocol>`_**
  ##
  ## **Also See**:
  ## * `proc protocol(URL)`_ which has the same behaviour as this function.
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
