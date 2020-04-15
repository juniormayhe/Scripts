# Test projects

We can avoid adding ExcludeFromCodeCoverage attribute in several files by just changing test project /Properties/AssemblyInfo.cs

```
using System.Diagnostics.CodeAnalysis;
[assembly: ExcludeFromCodeCoverage]
```
