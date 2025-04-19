#import "Basic";

LogLevel :: enum u8 { DEBUG :: 0; WARN; ERROR; INFO; OK; }

LogLeveLookupTable :: [#run enum_highest_value(LogLevel) + 1]string;

log_level_lookup_table :: #run -> LogLeveLookupTable {
    result: LogLeveLookupTable;
    result[LogLevel.DEBUG] = "[\e[36mDEBUG\e[0m]: "; // Cyan
    result[LogLevel.WARN]  = "[\e[33m WARN\e[0m]: "; // Yellow
    result[LogLevel.ERROR] = "[\e[31mERROR\e[0m]: "; // Red
    result[LogLevel.INFO]  = "[\e[34m INFO\e[0m]: "; // Blue
    result[LogLevel.OK]    = "[\e[32m   OK\e[0m]: "; // Green
    return result;
}

ValueWrapper :: struct {
    value:    Any;
    constant: bool;
}

debug :: ($codes: ..Code, caller := #caller_code) -> string #expand { #insert,scope(caller) #run logger_part_1(level=.DEBUG, ..codes); }
warn  :: ($codes: ..Code, caller := #caller_code) -> string #expand { #insert,scope(caller) #run logger_part_1(level=.WARN,  ..codes); }
error :: ($codes: ..Code, caller := #caller_code) -> string #expand { #insert,scope(caller) #run logger_part_1(level=.ERROR, ..codes); }
info  :: ($codes: ..Code, caller := #caller_code) -> string #expand { #insert,scope(caller) #run logger_part_1(level=.INFO,  ..codes); }
ok    :: ($codes: ..Code, caller := #caller_code) -> string #expand { #insert,scope(caller) #run logger_part_1(level=.OK,    ..codes); }

logger_part_1 :: (level: LogLevel, codes: ..Code) -> string {

    #import "Compiler";
    #import "Program_Print";

    sb: String_Builder;
    print(*sb, "logger_part_2(");
    print(*sb, "\"%\",", log_level_lookup_table[level]);
    for codes {
        print(*sb, "ValueWrapper.{");
            print(*sb, "value = "); print_expression(*sb, compiler_get_nodes(it));
            print(*sb, ",");
            print(*sb, "constant = is_constant("); print_expression(*sb, compiler_get_nodes(it)); print(*sb, ")");
        print(*sb, "}");

        if it_index != codes.count-1
            print(*sb, ",");
    }
    print(*sb, ");");

    return builder_to_string(*sb);
}

logger_part_2 :: (level: string, values: ..ValueWrapper) {
    print(level);
    for values {
        if it.value.type.type == {
            case .STRING;
                if it.constant {
                    print(it.value.value_pointer.(*string).*);
                } else {
                    print("\e[33m'%'\e[0m", it.value);
                }

            case .INTEGER; #through;
            case .FLOAT;
                print("\e[33m%\e[0m", it.value);
            case;
                print("\e[33m<%>\e[0m", it.value);
        }
    }
    print("\n");
}

main :: () {
    x := 1323;
    Z :: "Hello";
    runtime_string := "test_string";

    info("starting logging example!");
    debug("x: ", x, ", another number: ", 12, ", Z: ", Z);
    warn("runtime_string: ", runtime_string, ". What an epic runtime string it is...");
    error("Program took ", 0.00001, " milliseconds to load!");
    ok("Looks good to me!");
}
