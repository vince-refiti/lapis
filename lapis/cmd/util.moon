
import insert, concat from table
import escape_pattern from require "lapis.util"

split = (str, delim using escape_pattern) ->
  str ..= delim
  [part for part in str\gmatch "(.-)" .. escape_pattern delim]

-- wrap test based on tokens
wrap_text = (text, indent=0, max_width=80) ->
  width = max_width - indent
  words = split text, " "
  pos = 1
  lines = {}
  while pos <= #words
    line_len = 0
    line = {}
    while true
      word = words[pos]
      break if word == nil
      error "can't wrap text, words too long" if #word > width
      break if line_len + #word > width

      pos += 1
      insert line, word
      line_len += #word + 1 -- +1 for the space

    insert lines, concat line, " "

  concat lines, "\n" .. (" ")\rep indent

columnize = (rows, indent=2, padding=4, wrap=true) ->
  max = 0
  max = math.max max, #row[1] for row in *rows

  left_width = indent + padding + max

  formatted = for row in *rows
    padd = (max - #row[1]) + padding
    concat {
      (" ")\rep indent
      row[1]
      (" ")\rep padd
      wrap and wrap_text(row[2], left_width) or row[2]
    }

  concat formatted, "\n"

get_free_port = ->
  socket = require "socket"

  sock = socket.bind "*", 0
  _, port = sock\getsockname!
  sock\close!

  port

default_environment = do
  _env = nil
  ->
    if _env == nil
      import running_in_test from require "lapis.spec"
      if running_in_test!
        _env = "test"
      else
        _env = "development"
        pcall -> _env = require "lapis_environment"

    _env

parse_flags = (input) ->
  flags = {}

  filtered = for arg in *input
    if flag = arg\match "^%-%-?(.+)$"
      k,v = flag\match "(.-)=(.*)"
      if k
        flags[k] = v
      else
        flags[flag] = true
      continue
    arg

  flags, filtered

{ :columnize, :split, :get_free_port, :default_environment, :parse_flags }
