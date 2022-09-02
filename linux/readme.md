
# Linux scripts and snippets

Useful scripts and common tasks for daily use.

## List path and filenames with specific extension that contains the text MyMethod

```
locate *.cs | xargs grep -rl MyMethod
```
