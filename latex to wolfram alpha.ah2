#SingleInstance force
ListLines 0
KeyHistory 0
SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.

A_Clipboard:=latex_to_wolframAlpha(A_Clipboard)

ToolTip A_Clipboard
SoundPlay "*-1"
Sleep 1000

ExitApp

f3::Exitapp

latex_to_wolframAlpha(bak) {
    bak:=RegExReplace(bak, "\\degree", "°")
    bak:=RegExReplace(bak, "^\\frac{d}{d(\w)} (.*)$", "D[$2,$1]")
    bak:=StrReplace(bak, " ")
    bak:=StrReplace(bak, "\left(", "(")
    bak:=StrReplace(bak, "\right)", ")")
    RegExReplace_Forever(&bak
    ,"\\frac{d}{d(\w)}(\(((?>[^()]+|(?1))*)\))"
    ,"D[($3),$1]")
    bak:=RegExReplace(bak, "\\frac{d(\w)}{d(\w)}", "D[$1,$2]")
    RegExReplace_Forever(&bak
    ,"\\cos(\(((?>[^()]+|(?1))*)\))"
    ,"Cos[$2]")
    RegExReplace_Forever(&bak
    ,"\\frac(\{((?>[^{}]+|(?1))*)\})(\{((?>[^{}]+|(?2))*)\})"
    ,"Divide[$2,$4]")
    RegExReplace_Forever(&bak
    ,"\\sqrt(\{((?>[^{}]+|(?1))*)\})"
    ,"Sqrt[$2]")
    RegExReplace_Forever(&bak
    ,"(\(((?>[^()]+|(?1))*)\))\^(\{((?>[^{}]+|(?3))*)\})"
    ,"Power[($2),$4]")
    RegExReplace_Forever(&bak
    ,"(\w*)\^(\{((?>[^{}]+|(?1))*)\})"
    ,"Power[$1,$3]")
    bak:=StrReplace(bak, "(", "\(40(")
    bak:=StrReplace(bak, ")", "\(41)")
    bak:=StrReplace(bak, "\(40(", "\(40)")
    return bak
}

RegExReplace_Forever(&Haystack, NeedleRegEx, Replacement) {
    OutputVarCount:=1
    while (OutputVarCount) {
        try {
            Haystack:=RegExReplace(Haystack, NeedleRegEx, Replacement, &OutputVarCount)
        } catch as e {
            e2:=Error("Fail", -1)
        }
    }
}