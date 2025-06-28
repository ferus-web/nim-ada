## Low-level bindings to ada-url
##
## Copyright (C) 2025 Trayambak Rai

const lib = "libada.so"

{.passL: "-lada".}

{.push header: "<ada_c.h>", dynlib: lib.}
var ADA_URL_OMITTED* {.importc: "ada_url_omitted".}: int32 

type
  ada_string* {.final.} = object
    data*: cstring
    length*: uint64

  ada_owned_string* {.final.} = object
    data*: cstring
    length*: uint64

  ada_url_components* {.final.} = object
    protocolEnd*: uint32
    usernameEnd*: uint32
    hostStart*: uint32
    hostEnd*: uint32
    port*: uint32
    pathnameStart*: uint32
    searchStart*: uint32
    hashStart*: uint32

  ada_url* {.final.} = pointer

{.push cdecl, importc.}
proc ada_parse*(input: cstring, length: uint64): ada_url
proc ada_parse_with_base*(input: cstring, inputLength: uint64, base: cstring, baseLength: uint64): ada_url

proc ada_can_parse*(input: cstring, length: uint64): bool
proc ada_can_parse_with_base*(input: cstring, inputLength: uint64, base: cstring, baseLength: uint64): bool

proc ada_free*(res: ada_url)
proc ada_free_owned_string*(owned: ada_owned_string)
proc ada_copy*(input: ada_url): ada_url

proc ada_is_valid*(res: ada_url): bool

proc ada_get_origin*(res: ada_url): ada_owned_string
proc ada_get_href*(res: ada_url): ada_string
proc ada_get_username*(res: ada_url): ada_string
proc ada_get_password*(res: ada_url): ada_string
proc ada_get_port*(res: ada_url): ada_string
proc ada_get_hash*(res: ada_url): ada_string
proc ada_get_host*(res: ada_url): ada_string
proc ada_get_hostname*(res: ada_url): ada_string
proc ada_get_pathname*(res: ada_url): ada_string
proc ada_get_search*(res: ada_url): ada_string
proc ada_get_protocol*(res: ada_url): ada_string
proc ada_get_host_type*(res: ada_url): uint8
proc ada_get_scheme_type*(res: ada_url): uint8

proc ada_set_href*(res: ada_url, input: cstring, length: uint64): bool
proc ada_set_host*(res: ada_url, input: cstring, length: uint64): bool
proc ada_set_hostname*(res: ada_url, input: cstring, length: uint64): bool
proc ada_set_protocol*(res: ada_url, input: cstring, length: uint64): bool
proc ada_set_username*(res: ada_url, input: cstring, length: uint64): bool
proc ada_set_password*(res: ada_url, input: cstring, length: uint64): bool
proc ada_set_port*(res: ada_url, input: cstring, length: uint64): bool
proc ada_set_pathname*(res: ada_url, input: cstring, length: uint64): bool
proc ada_set_search*(res: ada_url, input: cstring, length: uint64): bool
proc ada_set_hash*(res: ada_url, input: cstring, length: uint64): bool

func ada_clear_port*(res: ada_url)
func ada_clear_hash*(res: ada_url)
func ada_clear_search*(res: ada_url)

func ada_has_credentials*(res: ada_url): bool
func ada_has_empty_hostname*(res: ada_url): bool
func ada_has_hostname*(res: ada_url): bool
func ada_has_non_empty_username*(res: ada_url): bool
func ada_has_non_empty_password*(res: ada_url): bool
func ada_has_port*(res: ada_url): bool
func ada_has_password*(res: ada_url): bool
func ada_has_hash*(res: ada_url): bool
func ada_has_search*(res: ada_url): bool

proc ada_get_components*(res: ada_url): ptr ada_url_components
proc ada_idna_to_unicode*(input: cstring, length: uint64): ada_owned_string
proc ada_idna_to_ascii*(input: cstring, length: uint64): ada_owned_string
{.pop.}

{.pop.}
