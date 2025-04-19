from strutils import join

type Level* = enum
    debug = "[\e[36mDEBUG\e[0m]: ",  # Cyan
    warn  = "[\e[33m WARN\e[0m]: ",  # Yellow
    error = "[\e[31mERROR\e[0m]: ",  # Red
    info  = "[\e[34m INFO\e[0m]: ",  # Blue
    ok    = "[\e[32m   OK\e[0m]: "   # Green

template toColorString*(input: SomeInteger|SomeFloat): string = "\e[33m" & $input & "\e[0m"
template toColorString*(input: static[string]):        string = input
template toColorString*(input: string):                string = "\e[33m'" & input & "'\e[0m"

template `()`*(level: static[Level]; text: varargs[string, `toColorString`]) =
    when not defined(silent) and (level != debug or not defined(release)):
        echo $level & text.join()
    else:
        discard

var cock_size = 12
var cock_name = "steve"
debug("The cock size: ", cock_size, ", name: ", cock_name)
