#!/usr/bin/tclsh
# Operators should not be placed on the beginning of a line
# Exceptions: ++,--, and pointer operations

set ops {
    oror
    andand
    or
    and
    xor
    assign
    plus
    minus
    divide
    plusassign
    minusassign
    xorassign
    orassign
    andassign
    star
}

foreach f [getSourceFileNames] {
    foreach t [getTokens $f 1 0 -1 -1 [concat $ops]] {
        set line [lindex $t 1]
        set column [lindex $t 2]
        set name [lindex $t 3]
        set previousTokens [getTokens $f $line 0 $line $column {}]
        if {$previousTokens == {}} {
            report $f $line "line should not begin with operator"
        } else {
            set lastToken [lindex $previousTokens end]
            set lastName [lindex $lastToken 3]
            set lastCol [lindex $lastToken 2]
            set lastLine [expr $line - 1]
            if {[lsearch {space} $lastName] != -1 && $lastCol == 0} {
               # puts "Found token at line: $line"
                while {$lastLine > 0} {
                    set lastlineTokens [getTokens $f $lastLine 0 [expr $lastLine + 1] 0 {}]
                    set tokenlen [llength $lastlineTokens]
                    #puts "line: $lastLine -> tokenlen: $tokenlen"
                    if {$tokenlen == 1} {
                        set lastLine [expr $lastLine - 1]
                        continue
                    }
                    set tokenName [lindex [lindex $lastlineTokens [expr [llength $lastlineTokens] - 2]] 3]
                    #puts "line: $lastLine -> check for space-only line"
                    if {$tokenlen == 2 && $tokenName == "space"} {
                        set lastLine [expr $lastLine - 1]
                        continue
                    }
                    break
                }
                #puts "$line: lastEffective token found: $tokenName"

                if {($name != "star") && ($name != "and") } {
                    report $f $line "line should not begin with operator"
                } else {
                    # if the last effective token is an operator or a semicolon we can start with an operator
                    # (it might be a pointer/address operator)
                    if {($tokenName != "semicolon") && ($tokenName != "comma") &&
                        ($tokenName != "rightbrace") && ($tokenName != "leftbrace") == -1} {
                    report $f $line "line should not begin with operator"
                    }
                }
            }
        }
    }
}
