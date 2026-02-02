```vbscript
Option Explicit


Sub ConvertRawUrlsToHyperlinks_NoWildcards()
    Dim rng As Range
    Dim startPos As Long
    Dim ch As String
    Dim urlText As String
    
    Application.ScreenUpdating = False
    
    Set rng = ActiveDocument.Content
    
    With rng.Find
        .ClearFormatting
        .Text = "http"
        .Forward = True
        .Wrap = wdFindStop
        .Format = False
        .MatchWildcards = False
    End With
    
    Do While rng.Find.Execute
        ' rng is positioned at the start of "http"
        startPos = rng.Start
        
        ' Move end forward until we hit a delimiter (end of URL)
        rng.End = rng.Start
        Do While rng.End < ActiveDocument.Content.End
            rng.End = rng.End + 1
            ch = rng.Characters.Last.Text
            
            ' Delimiters that typically end a URL in text
            If ch = " " Or ch = vbTab Or ch = vbCr Or ch = Chr(11) _
               Or ch = """" Or ch = "'" _
               Or ch = "<" Or ch = ">" _
               Or ch = "(" Or ch = ")" _
               Or ch = "[" Or ch = "]" _
               Or ch = "{" Or ch = "}" Then
                rng.End = rng.End - 1
                Exit Do
            End If
        Loop
        
        urlText = rng.Text
        urlText = TrimTrailingPunctuation(urlText)
        
        ' Reset range to the cleaned URL text length (in case we trimmed)
        rng.SetRange Start:=startPos, End:=startPos + Len(urlText)
        
        ' Skip if already hyperlinked
        If rng.Hyperlinks.Count = 0 Then
            ' Keep display text exactly as URL text
            ActiveDocument.Hyperlinks.Add Anchor:=rng, Address:=urlText, TextToDisplay:=urlText
        End If
        
        ' Continue searching after this URL
        rng.Collapse wdCollapseEnd
    Loop
    
    Application.ScreenUpdating = True
End Sub
```

```vbscript
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

'Trim common trailing punctuation that often sticks to pasted URLs
Private Function CleanUrl(ByVal s As String) As String
    s = Trim$(s)
    
    Do While Len(s) > 0
        Select Case Right$(s, 1)
            Case ".", ",", ";", ":", ")", "]", "}", "!", "?"
                s = Left$(s, Len(s) - 1)
            Case Else
                Exit Do
        End Select
    Loop
    
    CleanUrl = s
End Function
```

```vbscript
Sub ConvertQuotesToSmart()
    ' Enable AutoFormat for quotes
    Options.AutoFormatAsYouTypeReplaceQuotes = True
    
    ' Select entire document
    Selection.WholeStory
    
    ' Replace straight quotes with themselves to trigger AutoFormat
    With Selection.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .Text = """"
        .Replacement.Text = """"
        .Forward = True
        .Wrap = wdFindContinue
        .Format = False
        .MatchCase = False
        .MatchWholeWord = False
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
    End With
    
    Selection.Find.Execute Replace:=wdReplaceAll
    
    MsgBox "All quotes converted to smart quotes!"
End Sub
```

```vbscript
Sub ConvertToSmartDoubleQuotes()
    Dim findRange As Range
    
    Application.ScreenUpdating = False
    
    On Error Resume Next
    
    ' STEP 1: Fix RIGHT quote (") after em-dash ? should be LEFT quote (")
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = "—" & ChrW(8221)  ' em-dash + "
        .Replacement.Text = "—" & ChrW(8220)  ' em-dash + "
        .Execute Replace:=wdReplaceAll
    End With
    
    ' Fix straight quote (") after em-dash
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = "—" & Chr(34)  ' em-dash + "
        .Replacement.Text = "—" & ChrW(8220)  ' em-dash + "
        .Execute Replace:=wdReplaceAll
    End With
    
    ' STEP 2: Fix LEFT quote (") before em-dash ? should be RIGHT quote (")
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = ChrW(8220) & "—"  ' " + em-dash
        .Replacement.Text = ChrW(8221) & "—"  ' " + em-dash
        .Execute Replace:=wdReplaceAll
    End With
    
    ' Fix straight quote (") before em-dash
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = Chr(34) & "—"  ' " + em-dash
        .Replacement.Text = ChrW(8221) & "—"  ' " + em-dash
        .Execute Replace:=wdReplaceAll
    End With
    
    ' STEP 3: Fix RIGHT quote (") after en-dash (–)
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = "–" & ChrW(8221)
        .Replacement.Text = "–" & ChrW(8220)
        .Execute Replace:=wdReplaceAll
    End With
    
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = "–" & Chr(34)
        .Replacement.Text = "–" & ChrW(8220)
        .Execute Replace:=wdReplaceAll
    End With
    
    ' STEP 4: Fix LEFT quote (") before en-dash (–)
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = ChrW(8220) & "–"
        .Replacement.Text = ChrW(8221) & "–"
        .Execute Replace:=wdReplaceAll
    End With
    
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = Chr(34) & "–"
        .Replacement.Text = ChrW(8221) & "–"
        .Execute Replace:=wdReplaceAll
    End With
    
    ' STEP 5: Fix RIGHT quote (") after hyphen (-)
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = "-" & ChrW(8221)
        .Replacement.Text = "-" & ChrW(8220)
        .Execute Replace:=wdReplaceAll
    End With
    
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = "-" & Chr(34)
        .Replacement.Text = "-" & ChrW(8220)
        .Execute Replace:=wdReplaceAll
    End With
    
    ' STEP 6: Fix RIGHT quote (") after space
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = " " & ChrW(8221)
        .Replacement.Text = " " & ChrW(8220)
        .Execute Replace:=wdReplaceAll
    End With
    
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = " " & Chr(34)
        .Replacement.Text = " " & ChrW(8220)
        .Execute Replace:=wdReplaceAll
    End With
    
    ' STEP 7: Fix RIGHT quote (") after paragraph start
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = "^p" & ChrW(8221)
        .Replacement.Text = "^p" & ChrW(8220)
        .Execute Replace:=wdReplaceAll
    End With
    
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = "^p" & Chr(34)
        .Replacement.Text = "^p" & ChrW(8220)
        .Execute Replace:=wdReplaceAll
    End With
    
    ' STEP 8: Fix LEFT quote (") before period
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = ChrW(8220) & "."
        .Replacement.Text = ChrW(8221) & "."
        .Execute Replace:=wdReplaceAll
    End With
    
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = Chr(34) & "."
        .Replacement.Text = ChrW(8221) & "."
        .Execute Replace:=wdReplaceAll
    End With
    
    ' STEP 9: Fix LEFT quote (") before comma
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = ChrW(8220) & ","
        .Replacement.Text = ChrW(8221) & ","
        .Execute Replace:=wdReplaceAll
    End With
    
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = Chr(34) & ","
        .Replacement.Text = ChrW(8221) & ","
        .Execute Replace:=wdReplaceAll
    End With
    
    ' STEP 10: Fix LEFT quote (") before space
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = ChrW(8220) & " "
        .Replacement.Text = ChrW(8221) & " "
        .Execute Replace:=wdReplaceAll
    End With
    
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = Chr(34) & " "
        .Replacement.Text = ChrW(8221) & " "
        .Execute Replace:=wdReplaceAll
    End With
    
    ' STEP 11: Fix LEFT quote (") before other punctuation
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = ChrW(8220) & ";"
        .Replacement.Text = ChrW(8221) & ";"
        .Execute Replace:=wdReplaceAll
    End With
    
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = ChrW(8220) & ":"
        .Replacement.Text = ChrW(8221) & ":"
        .Execute Replace:=wdReplaceAll
    End With
    
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = ChrW(8220) & "!"
        .Replacement.Text = ChrW(8221) & "!"
        .Execute Replace:=wdReplaceAll
    End With
    
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = ChrW(8220) & "?"
        .Replacement.Text = ChrW(8221) & "?"
        .Execute Replace:=wdReplaceAll
    End With
    
    On Error GoTo 0
    
    Application.ScreenUpdating = True
    
    MsgBox "Smart double quotes fixed.", vbInformation, "Complete"
End Sub
```

```vbscript
Sub ReplaceAmpersandWithEt()
    Dim findRange As Range
    
    Application.ScreenUpdating = False
    
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = "&"
        .Replacement.Text = "et"
        .Execute Replace:=wdReplaceAll
    End With
    
    Application.ScreenUpdating = True
    
    MsgBox "All '&' replaced with 'et'.", vbInformation, "Complete"
End Sub

Sub ConvertToSmartSingleQuotes()
    Dim findRange As Range
    Dim totalReplacements As Long
    Dim currentReplacements As Long
    
    Application.ScreenUpdating = False
    
    On Error GoTo ErrorHandler
    
    totalReplacements = 0
    
    ' Convert apostrophes in contractions and possessives
    ' Pattern: letter + straight apostrophe + letter
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = True
        .Wrap = wdFindContinue
        
        ' Contractions and possessives: letter + ' + letter
        .Text = "([a-zA-Z])'([a-zA-Z])"
        .Replacement.Text = "\1" & ChrW(8217) & "\2"
        .Execute Replace:=wdReplaceAll, ReplaceWith:=.Replacement.Text
        currentReplacements = Val(findRange.Find.Found)
        totalReplacements = totalReplacements + currentReplacements
    End With
    
    ' Handle possessives at end of words (ending with 's)
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = True
        .Wrap = wdFindContinue
        
        ' Possessive: letter + 's
        .Text = "([a-zA-Z])'s"
        .Replacement.Text = "\1" & ChrW(8217) & "s"
        .Execute Replace:=wdReplaceAll
    End With
    
    ' Handle contractions ending in n't, 'll, 're, 've, 'd, 'm
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = True
        .Wrap = wdFindContinue
        
        .Text = "([a-zA-Z])'(t|ll|re|ve|d|m)"
        .Replacement.Text = "\1" & ChrW(8217) & "\2"
        .Execute Replace:=wdReplaceAll
    End With
    
    ' Handle years: '90s, '80s, etc.
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = True
        .Wrap = wdFindContinue
        
        .Text = "([  ^13])'([0-9][0-9]s)"
        .Replacement.Text = "\1" & ChrW(8217) & "\2"
        .Execute Replace:=wdReplaceAll
    End With
    
    ' Handle possessive s' (plural possessive)
    Set findRange = ActiveDocument.Range
    With findRange.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .MatchWildcards = False
        .Wrap = wdFindContinue
        
        .Text = "s'"
        .Replacement.Text = "s" & ChrW(8217)
        .Execute Replace:=wdReplaceAll
    End With
    
CleanUp:
    Application.ScreenUpdating = True
    
    ' Always show success if we reached here without errors
    MsgBox "Smart apostrophe conversion complete.", vbInformation, "Complete"
    
    Exit Sub

ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "An error occurred: " & Err.Description, vbCritical, "Error"
    Resume CleanUp
End Sub
```

```vbscript
Sub FormatWordToItalic()
    Dim searchText As String
    Dim originalSelection As Range
    Dim findRange As Range
    Dim matchCount As Long
    
    ' Store the original selection position
    Set originalSelection = Selection.Range
    
    ' Check if text is selected
    If Selection.Type = wdSelectionIP Or Len(Trim(Selection.Text)) = 0 Then
        ' No text selected - show input dialog
        searchText = InputBox("Enter the word to format as italic:", "Format Word to Italic")
        
        ' Check if user cancelled or entered empty text
        If searchText = "" Then
            MsgBox "No word entered. Operation cancelled.", vbInformation, "Cancelled"
            Exit Sub
        End If
    Else
        ' Use selected text as search term
        searchText = Trim(Selection.Text)
        
        ' Remove paragraph marks if present
        searchText = Replace(searchText, vbCr, "")
        searchText = Replace(searchText, vbLf, "")
    End If
    
    ' Initialize counter
    matchCount = 0
    
    ' Set up the Find range to search entire document
    Set findRange = ActiveDocument.Range
    
    With findRange.Find
        .ClearFormatting
        .Text = searchText
        .MatchCase = True          ' Case-sensitive matching
        .MatchWholeWord = True     ' Only exact whole word matches
        .MatchWildcards = False
        .Forward = True
        .Wrap = wdFindStop
        
        ' Execute the find and format loop
        Do While .Execute
            findRange.Font.Italic = True
            matchCount = matchCount + 1
            
            ' Move the range after the found text to continue searching
            findRange.Collapse wdCollapseEnd
            findRange.End = ActiveDocument.Range.End
        Loop
    End With
    
    ' Restore original selection/cursor position
    originalSelection.Select
    
    ' Show results
    If matchCount > 0 Then
        MsgBox matchCount & " instance(s) of '" & searchText & "' formatted to italic.", _
               vbInformation, "Complete"
    Else
        MsgBox "No matches found for '" & searchText & "'.", vbInformation, "No Matches"
    End If
End Sub
```

```vbscript
Sub FormatWordToItalicFast()
    Dim searchText As String
    Dim originalSelection As Range
    Dim matchCount As Long
    
    ' Store the original selection position
    Set originalSelection = Selection.Range
    
    ' Check if text is selected
    If Selection.Type = wdSelectionIP Or Len(Trim(Selection.Text)) = 0 Then
        searchText = InputBox("Enter the word to format as italic:", "Format Word to Italic")
        If searchText = "" Then
            MsgBox "No word entered. Operation cancelled.", vbInformation, "Cancelled"
            Exit Sub
        End If
    Else
        searchText = Trim(Selection.Text)
        searchText = Replace(searchText, vbCr, "")
        searchText = Replace(searchText, vbLf, "")
    End If
    
    ' Disable screen updating for performance
    Application.ScreenUpdating = False
    
    On Error GoTo ErrorHandler
    
    matchCount = 0
    
    ' Search only the main document story (faster for complex documents)
    With ActiveDocument.Content.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .Replacement.Font.Italic = True
        
        .Text = searchText
        .MatchCase = True
        .MatchWholeWord = True
        .MatchWildcards = False
        .Forward = True
        .Wrap = wdFindContinue
        
        ' Use Replace to count and format in one pass
        matchCount = .Execute(Replace:=wdReplaceAll)
    End With
    
CleanUp:
    Application.ScreenUpdating = True
    originalSelection.Select
    
    If matchCount > 0 Then
        MsgBox matchCount & " instance(s) of '" & searchText & "' formatted to italic.", _
               vbInformation, "Complete"
    Else
        MsgBox "No matches found for '" & searchText & "'.", vbInformation, "No Matches"
    End If
    
    Exit Sub

ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "An error occurred: " & Err.Description, vbCritical, "Error"
    Resume CleanUp
End Sub
```

