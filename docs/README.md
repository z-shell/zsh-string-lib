<h1> Zsh String Lib </h1>

# Introduction

A string library for Zsh. Its founding function was parsing of JSON.

## List Of The Functions

### @str-parse-json

Parses the buffer (`$1`) with JSON and returns:

1. Fields for the given key (`$2`) in the given hash (`$3`).
2. The hash looks like follows:

   ```txt
   1/1 → strings at the level 1 of the 1st object
   1/2 → strings at the level 1 of the 2nd object
   …
   2/1 → strings at 2nd level of the 1st object
   …
   ```

   The strings are parseable with `"${(@Q)${(@z)value}"`, i.e.:
   they're concatenated and quoted strings found in the JSON.

Example:

```json
{
  "zi-ices": {
    "default": {
      "wait": "1",
      "lucid": "",
      "as": "program",
      "pick": "fzy",
      "make": ""
    },
    "bgn": {
      "wait": "1",
      "lucid": "",
      "as": "null",
      "make": "",
      "sbin": "fzy;contrib/fzy-*"
    }
  }
}
```

Will result in:

```zsh
local -A Strings
Strings[1/1]="zi-ices"
Strings[2/1]="default $'\0'--object--$'\0' bgn $'\0'--object--$'\0'"
Strings[3/1]='wait 1 lucid \  as program pick fzy make \ '
Strings[3/2]='wait 1 lucid \  as null make \  sbin fzy\;contrib/fzy-\*'
```

So that when you e.g.: expect a key `bgn` but don't know at which
position, you can do:

```zsh
local -A Strings
@str-parse-json "$json" "zi-ices" Strings

integer pos
# (I) flag returns index at which the `bgn' string
# has been found in the array – the result of the
# (z)-split of the Strings[2/1] string
pos=${${(@Q)${(@z)Strings[2/1]}}[(I)bgn]}
if (( pos )) {
  local -A ices
  ices=( "${(@Q)${(@z)Strings[3/$(( (pos+1) / 2 ))]}}" )
  # Use the `ices' hash holding the values of the `bgn' object
  …
}
```

Note that the `$'\0'` is correctly dequoted by `Q` flag into the null byte.

Arguments:

1. The buffer with JSON.
2. The key in the JSON that should be mapped to the result (i.e.: it's possible
   to map only a subset of the input). It must be the first key in the object to
   map.
3. The name of the output hash parameter.

### @str-read-all

Consumes whole data from given file descriptor and stores the string under the
given (`$2`) parameter, which is `REPLY` by default.

The reason to create this function is speed – it's much faster than `read -d ''`.

It can try hard to read the whole data by retrying multiple times (`10` by
default) and sleeping before each retry (not done by default).

Arguments:

1. File descriptor (a number; use `1` for stdin) to be read from.
2. Name of output variable (default: `REPLY`).
3. Numer of retries (default: `10`).
4. Sleep time after each retry (a float; default: `0`).

Example:

```zsh
exec {FD}< =( cat /etc/motd )
@str-read-all $FD
print -r -- $REPLY
…
```

### @str-ng-match

Returns a non-greedy match of the given pattern (`$2`) in the given string
(`$1`).

1. The string to match in.
2. The pattern to match in the string.

Return value:

- `$REPLY` – the matched string, if found,
- return code: `0` if there was a match found, otherwise `1`.

Example:

```zsh
if @str-ng-match "abb" "a*b"; then
  print -r -- $REPLY
fi
Output: ab
```

### @str-ng-matches

Returns all non-greedy matches of the given pattern in the given list of
strings.

Input:

- `$1` … `$n-1` - the strings to match in,
- `$n` - the pattern to match in the strings.

Return value:

- `$reply` – contains all the matches,
- `$REPLY` - holds the first match,
- return code: `0` if there was any match found, otherwise `1`.

Example:

```zsh
arr=( a1xx ayy a2xx )
if @str-ng-matches ${arr[@]} "a*x"; then
   print -rl -- $reply
fi

Outout:
a1x
a2x
```

### @str-read-ini

Reads an INI file.

Arguments:

1. Path to the ini file to parse.
2. Name of output hash (`INI` by default).
3. Prefix for keys in the hash (can be empty).

Writes to given hash under keys built in following way: `${3}<section>_field`.
Values are the values from the ini file.

### @str-read-toml

Reads a TOML file with support for single-level array.

1. Path to the TOML file to parse.
2. Name of output hash (`TOML` by default).
3. Prefix for keys in the hash (can be empty).

Writes to given hash under keys built in following way: `${3}<section>_field`.
Values are the values from the TOML file.

The values can be quoted and concatenated strings if they're an array. For
example:

```ini
[sec]
array = [ val1, "value 2", value&3 ]
```

Then the fields of the hash will be:

```zsh
TOML[<sec>_array]="val1 value\ 2 value\&3"
```

To retrieve the array stored in such way, use the substitution
`"${(@Q)${(@z)TOML[<sec>_array]}}"`:

```zsh
local -a array
array=( "${(@Q)${(@z)TOML[<sec>_array]}}" )
```

(The substitution first splits the input string as if Zsh would split it on the
command line – with the `(z)` flag, and then removes one level of quoting with
the `(Q)` flag).

### @str-dump

Dumps the contents of the variable, whether it's being a scalar, an array or
a hash. The contents of the hash are sorted on the keys numerically, i.e.: by
using `(on)` flags.

An option `-q` can be provided: it'll enable quoting of the printed data with
the `q`-flag (i.e.: backslash quoting).

Basically, the function Is an alternative to `declare -p`, with a different
output format, more dump-like.

Arguments:

1. The name of the variable of which contents should be dumped.

Example:

```zsh
array=( "" "a value" "test" )
@str-dump -q array
```

Output:

```
''
a\ value
test
```

```zsh
typeset -A hash=( "a key" "a value" key value )
@str-dump -q hash
```

Output:

```
a\ key: a\ value
key: value
```
