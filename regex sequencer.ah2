ListLines 0
#SingleInstance force
SendMode "Input"	; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir	; Ensures a consistent starting directory.
KeyHistory 0

text := "
( `
; program a b                       REM sends (a) and (b)
; program """a"""                   REM sends ("a")
; program """a b"""                 REM sends ("a) and (b")
; program """"Hello,""" Mike said." REM sends ("Hello," Mike said.)
; program ""a""b""c""d""            REM sends (abcd) since the "" groups wrap nothing
; program "hello to """quotes""     REM sends (hello to "quotes")
; program """"hello world""         REM sends ("hello world")
; program """hello" world""         REM sends ("hello world")
; program """hello "world""         REM sends ("hello) and (world")
; program "hello ""world"""         REM sends (hello "world")
; program "hello """world""         REM sends (hello "world")

; program (.*?)\s*REM sends \((.*?)\)(?: and \((.*?)\))?.*?$
; {$1}-> {$2}-> {$3}

; {a b} -> {a}, {b}
; {"""a"""} -> {"a"}, {}
; {"""a b"""} -> {"a}, {b"}
; {""""Hello,""" Mike said."} -> {"Hello," Mike said.}, {}
; {""a""b""c""d""} -> {abcd}, {}
; {"hello to """quotes""} -> {hello to "quotes"}, {}
; {""""hello world""} -> {"hello world"}, {}
; {"""hello" world""} -> {"hello world"}, {}
; {"""hello "world""} -> {"hello}, {world"}
; {"hello ""world"""} -> {hello "world"}, {}
; {"hello """world""} -> {hello "world"}, {}

; , {}

; {a b} -> {a}, {b}
; {"""a"""} -> {"a"}
; {"""a b"""} -> {"a}, {b"}
; {""""Hello,""" Mike said."} -> {"Hello," Mike said.}
; {""a""b""c""d""} -> {abcd}
; {"hello to """quotes""} -> {hello to "quotes"}
; {""""hello world""} -> {"hello world"}
; {"""hello" world""} -> {"hello world"}
; {"""hello "world""} -> {"hello}, {world"}
; {"hello ""world"""} -> {hello "world"}
; {"hello """world""} -> {hello "world"}

; "
; `"

; {a b} -> {a}, {b}
; {`"`"`"a`"`"`"} -> {`"a`"}
; {`"`"`"a b`"`"`"} -> {`"a}, {b`"}
; {`"`"`"`"Hello,`"`"`" Mike said.`"} -> {`"Hello,`" Mike said.}
; {`"`"a`"`"b`"`"c`"`"d`"`"} -> {abcd}
; {`"hello to `"`"`"quotes`"`"} -> {hello to `"quotes`"}
; {`"`"`"`"hello world`"`"} -> {`"hello world`"}
; {`"`"`"hello`" world`"`"} -> {`"hello world`"}
; {`"`"`"hello `"world`"`"} -> {`"hello}, {world`"}
; {`"hello `"`"world`"`"`"} -> {hello `"world`"}
; {`"hello `"`"`"world`"`"} -> {hello `"world`"}

; [{}]
; "
)"

#HotIf InStr(WinGetTitle("A"), "regex_sequence")
$f1:: {
  send "^a^c"
  sleep 100
  sequenceRegex(A_Clipboard, clipSend)
}
#HotIf

clipSend(text) {
  A_Clipboard := text
  send "^v"
}
; d sequenceRegex(text)

sequenceRegex(text, callback) {
  text := StrReplace(text, "`r")
  text := Trim(text, "`n")
  arr := StrSplit(text, "`n`n")
  HayStack := arr[1]
  finalStr := HayStack

  loop arr.Length / 2 {
    regexAndReplacement := StrSplit(arr[A_Index * 2], "`n")

    if (!(regexAndReplacement.length == 1 || regexAndReplacement.length == 2)) {
      if (regexAndReplacement.length == 0) {
        MsgBox "regexAndReplacement.length == 0"
      } else {
        MsgBox "regexAndReplacement.length > 2"
        MsgBox regexAndReplacement[1]
        MsgBox regexAndReplacement[2]
      }
      ExitApp
    }

    replacementExpr := regexAndReplacement.Length == 2 ? regexAndReplacement[2] : ""

    try {
      HayStack := RegExReplace(HayStack, "m)" regexAndReplacement[1], replacementExpr, &OutputVarCount)
    } catch as e {
      ; MsgBox e.Message "`nLine: " e.Line
      ; return
    ; }
    ; if (OutputVarCount == 0) {
      ; p "not found"
      ; d HayStack

      MyGui := Gui()
      MyGui.SetFont("s12 w500 q5", "Consolas")

      HayStack_Edit := MyGui.AddEdit(, HayStack)
      HayStack_Edit.GetPos(&X, &Y, &Width, &Height)

      regex_Edit := MyGui.AddEdit("w" Width, regexAndReplacement[1])

      replacement_Edit := MyGui.AddEdit("w" Width, replacementExpr)
      greenRed_Div := MyGui.AddProgress("cRed w" Width, 100)
      replaced_Edit := MyGui.AddEdit("w" Width, HayStack)

      Edit_Changed.greenRed_Div := greenRed_Div
      Edit_Changed(GuiCtrlObj, Info) {
        ; p regex_Edit.Text
        try {
          replaced := RegExReplace(HayStack_Edit.Text, "m)" regex_Edit.Text, replacement_Edit.Text, &OutputVarCount)
        } catch as e {
          return
        }
        if (OutputVarCount) {
          greenRed_Div.Opt("cBlue")
          ; Edit_Changed.greenRed_Div.BackColor := "Blue"
        } else {
          greenRed_Div.Opt("cRed")
          ; Edit_Changed.greenRed_Div.BackColor := "Red"
        }
        replaced_Edit.Text := replaced
      }
      HayStack_Edit.OnEvent("Change", Edit_Changed)	;The control's value changes.
      regex_Edit.OnEvent("Change", Edit_Changed)	;The control's value changes.
      replacement_Edit.OnEvent("Change", Edit_Changed)	;The control's value changes.
      replaced_Edit.OnEvent("Change", Edit_Changed)	;The control's value changes.

      Submit_Button := MyGui.AddButton("Default Hidden h0 w0")
      Submit_Button.OnEvent("Click", Submit_Button_Clicked.Bind(,,callback,&finalStr))
      Submit_Button_Clicked(GuiCtrlObj, Info, callback, &finalStr) {
        regex := regex_Edit.Text
        if (regex == "") {
          return
        }
        finalStr .= "`n`n" regex

        replacement := replacement_Edit.Text
        if (replacement !== "") {
          finalStr .= "`n" replacement
        }
        HayStack := replaced_Edit.Text	;we need to update HayStack
        finalStr .= "`n`n" HayStack

        ;concat the rest of it
        n := continueAt
        stop := arr.Length + 1
        ; even number for regex
        while (n < stop) {
          regexAndReplacement := StrSplit(arr[n], "`n")
          replacementExpr := regexAndReplacement.Length == 2 ? regexAndReplacement[2] : ""
          HayStack := RegExReplace(HayStack, "m)" regexAndReplacement[1], replacementExpr)	;we don't care if OutputVarCount == 0 anymore

          finalStr .= "`n`n" regexAndReplacement[1]
          if (replacementExpr) {
            finalStr .= "`n" replacementExpr
          }
          finalStr .= "`n`n" HayStack

          n += 2
        }
        MyGui.Destroy()
        callback(finalStr)
      }

      regex_Edit.Focus()
      MyGui.Show()
      continueAt := (A_Index + 1) * 2
      return
      ; n:=A_Index
      ; len:=arr.Length

    }

    finalStr .= "`n`n" regexAndReplacement[1]
    if (replacementExpr) {
      finalStr .= "`n" replacementExpr
    }
    finalStr .= "`n`n" HayStack

  }
  callback(finalStr)
}

return

f3:: Exitapp