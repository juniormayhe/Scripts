# Expose internals to test project

To expose methods and classes marked as internal to a test project, add in Properties/AssemblyInfo.cs

```
using System.Runtime.CompilerServices;
[assembly: InternalsVisibleTo("TestProjectNamespace")]
```
