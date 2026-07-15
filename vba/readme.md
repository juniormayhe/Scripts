
```vbscript
Option Explicit

'=====================================================================
'  SHARED PERFORMANCE HARNESS
'  Every public macro brackets its work in PerfBegin / PerfEnd.
'  These save and restore application state, so an error mid-run
'  cannot leave Word with ScreenUpdating off or Pagination disabled.
'=====================================================================

Private g_Screen      As Boolean
Private g_Pagination  As Boolean
Private g_Revisions   As Boolean
Private g_AutoQuotes  As Boolean
Private g_Depth       As Long

Private Sub PerfBegin()
    ' Re-entrancy guard: nested calls must not clobber the saved state.
    g_Depth = g_Depth + 1
    If g_Depth > 1 Then Exit Sub

    g_Screen = Application.ScreenUpdating
    g_Pagination = Application.Options.Pagination
    g_Revisions = ActiveDocument.TrackRevisions
    g_AutoQuotes = Options.AutoFormatAsYouTypeReplaceQuotes

    Application.ScreenUpdating = False

    ' THE big one on macOS. Word re-flows the whole layout on every
    ' content mutation; on a 500-page document this is what you are
    ' actually waiting for, not the Find itself.
    Application.Options.Pagination = False

    ' Revision marks on hundreds of hits add minutes and bloat the file.
    ActiveDocument.TrackRevisions = False
End Sub

Private Sub PerfEnd()
    g_Depth = g_Depth - 1
    If g_Depth > 0 Then Exit Sub

    Options.AutoFormatAsYouTypeReplaceQuotes = g_AutoQuotes
    ActiveDocument.TrackRevisions = g_Revisions
    Application.Options.Pagination = g_Pagination
    Application.ScreenUpdating = g_Screen
    Application.ScreenRefresh
End Sub

'---------------------------------------------------------------------
'  One-line replace-all against the main story.
'  Resets EVERY Find property on each call, because Word's Find state
'  is global and sticky - inheriting a stale .MatchWildcards or
'  .MatchCase from a previous macro is a classic source of "it worked
'  yesterday" bugs.
'  Returns True if at least one replacement was made.
'---------------------------------------------------------------------
Private Function ReplaceAll(ByVal findText As String, _
                            ByVal replText As String, _
                            ByVal useWildcards As Boolean, _
                            Optional ByVal caseSensitive As Boolean = True) As Boolean
    Dim r As Range
    Set r = ActiveDocument.Content

    With r.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .Text = findText
        .Replacement.Text = replText
        .Forward = True
        .Wrap = wdFindContinue
        .Format = False
        .MatchCase = caseSensitive
        .MatchWholeWord = False
        .MatchWildcards = useWildcards
        .MatchSoundsLike = False
        .MatchAllWordForms = False
        ReplaceAll = .Execute(Replace:=wdReplaceAll)
    End With
End Function

'---------------------------------------------------------------------
'  Curly-quote character constants (avoids ChrW noise inline).
'---------------------------------------------------------------------
Private Function LDQ() As String: LDQ = ChrW(8220): End Function  ' "
Private Function RDQ() As String: RDQ = ChrW(8221): End Function  ' "
Private Function LSQ() As String: LSQ = ChrW(8216): End Function  ' '
Private Function RSQ() As String: RSQ = ChrW(8217): End Function  ' '
```

```vbscript
'=====================================================================
'  URL -> HYPERLINK
'
'  Old approach: find "http", then walk forward ONE CHARACTER AT A TIME
'  calling rng.Characters.Last.Text and comparing ActiveDocument.
'  Content.End on every step. Each of those is a COM round-trip into
'  Word's object model. A single 60-character URL cost ~120 of them.
'
'  New approach: one wildcard pattern matches the entire URL in a
'  single Find hit. Zero per-character work.
'
'  Second fix: Hyperlinks.Add REPLACES text with a field, which shifts
'  every character position after it. The old code kept searching
'  forward from a range it had just invalidated. We now collect all
'  match offsets first, then apply hyperlinks in REVERSE order so
'  earlier offsets stay valid.
'=====================================================================
Sub ConvertRawUrlsToHyperlinks()
    Dim r          As Range
    Dim starts()   As Long
    Dim lengths()  As Long
    Dim n          As Long
    Dim i          As Long
    Dim urlText    As String
    Dim pattern    As String
    Dim added      As Long

    PerfBegin
    On Error GoTo Cleanup

    ' Negated class = "any char that does NOT end a URL".
    ' ^13 paragraph mark, ^09 tab, ^11 line break, space, quotes,
    ' brackets, angle brackets. Note: [ and ] must be escaped inside
    ' a class; ^13 works in wildcard mode but ^p does NOT.
    pattern = "http[s]{0,1}://[!^13^09^11 " & _
              Chr(34) & "'<>()\[\]{}" & _
              LSQ() & RSQ() & LDQ() & RDQ() & "]{1,}"

    ReDim starts(0 To 255)
    ReDim lengths(0 To 255)
    n = 0

    Set r = ActiveDocument.Content
    With r.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .Text = pattern
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindStop            ' stop at end; do not loop forever
        .Format = False
        .MatchCase = False
        .MatchWholeWord = False
        .MatchWildcards = True
        .MatchSoundsLike = False
        .MatchAllWordForms = False

        Do While .Execute
            If n > UBound(starts) Then
                ReDim Preserve starts(0 To (n * 2))
                ReDim Preserve lengths(0 To (n * 2))
            End If
            starts(n) = r.Start
            lengths(n) = r.End - r.Start
            n = n + 1
            r.Collapse wdCollapseEnd  ' Find auto-extends a collapsed range to EOD
        Loop
    End With

    ' Apply in reverse: inserting a hyperlink field at offset X only
    ' shifts offsets > X, so working backwards keeps every stored
    ' offset valid without a single recalculation.
    For i = n - 1 To 0 Step -1
        Set r = ActiveDocument.Range(starts(i), starts(i) + lengths(i))
        urlText = TrimTrailingPunctuation(r.Text)

        If Len(urlText) > 0 Then
            Set r = ActiveDocument.Range(starts(i), starts(i) + Len(urlText))
            If r.Hyperlinks.Count = 0 Then
                ActiveDocument.Hyperlinks.Add Anchor:=r, _
                                              Address:=urlText, _
                                              TextToDisplay:=urlText
                added = added + 1
            End If
        End If
    Next i

Cleanup:
    PerfEnd
    If Err.Number <> 0 Then
        MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical
    Else
        MsgBox added & " hyperlink(s) created from " & n & " URL(s) found.", _
               vbInformation, "Complete"
    End If
End Sub

'---------------------------------------------------------------------
'  Strip punctuation that commonly sticks to a pasted URL.
'  (Was duplicated as CleanUrl - that copy is deleted.)
'---------------------------------------------------------------------
Private Function TrimTrailingPunctuation(ByVal s As String) As String
    s = Trim$(s)
    Do While Len(s) > 0
        Select Case Right$(s, 1)
            Case ".", ",", ";", ":", "!", "?", ")", "]", "}", """", "'"
                s = Left$(s, Len(s) - 1)
            Case Else
                Exit Do
        End Select
    Loop
    TrimTrailingPunctuation = s
End Function
```

```vbscript
'=====================================================================
'  SMART QUOTES - replaces ConvertQuotesToSmart, ConvertToSmartDoubleQuotes
'  AND ConvertToSmartSingleQuotes (all three).
'
'  The old ConvertToSmartDoubleQuotes ran 20 full-document passes,
'  each hand-coding one context rule (after em-dash, after en-dash,
'  after space, before comma...). Word already ships a context engine
'  that does exactly this: the AutoFormat smart-quote rule, which
'  fires during Find/Replace.
'
'  So: normalise every curly quote back to straight (2 passes), then
'  let Word's own engine re-curl them with correct handedness
'  (2 passes). 20 passes -> 4, and the context rules are Word's, not
'  a hand-rolled approximation with ordering conflicts.
'
'  Known Word limitation, patched afterwards: Word gives '90s an
'  OPENING single quote. It should be a closing one (it marks elision).
'=====================================================================
Sub ConvertToSmartQuotes()
    Dim savedStart As Long, savedEnd As Long

    PerfBegin
    On Error GoTo Cleanup

    ' Live ranges shift under replacement. Store plain offsets.
    savedStart = Selection.Range.Start
    savedEnd = Selection.Range.End

    ' --- Stage 1: normalise curly -> straight (2 wildcard passes) ---
    ReplaceAll "[" & LDQ() & RDQ() & "]", Chr(34), True
    ReplaceAll "[" & LSQ() & RSQ() & "]", Chr(39), True

    ' --- Stage 2: let Word's AutoFormat engine apply handedness ---
    Options.AutoFormatAsYouTypeReplaceQuotes = True
    ReplaceAll Chr(34), Chr(34), False
    ReplaceAll Chr(39), Chr(39), False
    Options.AutoFormatAsYouTypeReplaceQuotes = False

    ' --- Stage 3: patch Word's elision blind spot ---
    ' '90s / '80s / 'til - Word opens these; they should close.
    ReplaceAll LSQ() & "([0-9]{2}s)", RSQ() & "\1", True
    ReplaceAll LSQ() & "(til)", RSQ() & "\1", True, False

Cleanup:
    ActiveDocument.Range(savedStart, savedEnd).Select
    PerfEnd
    If Err.Number <> 0 Then
        MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical
    Else
        MsgBox "Smart quotes applied.", vbInformation, "Complete"
    End If
End Sub
```

```vbscript
'=====================================================================
'  AMPERSAND -> "et"
'  Was already single-pass; only the harness and explicit Find state
'  are added. See the caveat below the module.
'=====================================================================
Sub ReplaceAmpersandWithEt()
    PerfBegin
    On Error GoTo Cleanup

    ReplaceAll "&", "et", False

Cleanup:
    PerfEnd
    If Err.Number <> 0 Then
        MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical
    Else
        MsgBox "All '&' replaced with 'et'.", vbInformation, "Complete"
    End If
End Sub
```

```vbscript
'=====================================================================
'  ITALICISE A WORD
'  Replaces both FormatWordToItalic and FormatWordToItalicFast.
'
'  Old FormatWordToItalic: O(n^2). Every iteration did
'  findRange.End = ActiveDocument.Range.End, rebuilding a
'  rest-of-document range, then re-scanned from the collapse point.
'  Plus one repagination + one undo record per hit.
'
'  Old FormatWordToItalicFast: right idea, but .Execute(Replace:=...)
'  returns a Boolean. matchCount was always -1 or 0.
'
'  Fix: a cheap count pass (touches nothing, so no repagination),
'  then ONE internal wdReplaceAll to apply the format.
'  "^&" in the replacement means "re-insert what was found", so the
'  only thing that changes is the italic attribute.
'=====================================================================
Sub FormatWordToItalic()
    Dim searchText As String
    Dim savedStart As Long, savedEnd As Long
    Dim r          As Range
    Dim matchCount As Long

    savedStart = Selection.Range.Start
    savedEnd = Selection.Range.End

    If Selection.Type = wdSelectionIP Or Len(Trim(Selection.Text)) = 0 Then
        searchText = InputBox("Enter the word to format as italic:", _
                              "Format Word to Italic")
        If searchText = "" Then Exit Sub
    Else
        searchText = Trim(Replace(Replace(Selection.Text, vbCr, ""), vbLf, ""))
    End If

    PerfBegin
    On Error GoTo Cleanup

    ' Pass 1: count. No formatting applied, so no layout work at all.
    Set r = ActiveDocument.Content
    With r.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .Text = searchText
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindStop
        .Format = False
        .MatchCase = True
        .MatchWholeWord = True
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
        Do While .Execute
            matchCount = matchCount + 1
        Loop
    End With

    ' Pass 2: format everything inside Word's engine.
    ' One undo record, one repagination, one scan.
    If matchCount > 0 Then
        Set r = ActiveDocument.Content
        With r.Find
            .ClearFormatting
            .Replacement.ClearFormatting
            .Replacement.Font.Italic = True
            .Text = searchText
            .Replacement.Text = "^&"      ' re-insert the found text verbatim
            .Forward = True
            .Wrap = wdFindContinue
            .Format = True
            .MatchCase = True
            .MatchWholeWord = True
            .MatchWildcards = False
            .MatchSoundsLike = False
            .MatchAllWordForms = False
            .Execute Replace:=wdReplaceAll
        End With
    End If

Cleanup:
    ActiveDocument.Range(savedStart, savedEnd).Select
    PerfEnd
    If Err.Number <> 0 Then
        MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical
    ElseIf matchCount > 0 Then
        MsgBox matchCount & " instance(s) of '" & searchText & _
               "' formatted to italic.", vbInformation, "Complete"
    Else
        MsgBox "No matches found for '" & searchText & "'.", _
               vbInformation, "No Matches"
    End If
End Sub
```
