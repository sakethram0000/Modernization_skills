# Stop list

If discovery finds any item below, write it in `discovery-report.md` under "Human decision"
and do not rewrite it silently.

| What you found | Why you stop | What to ask the human |
|---|---|---|
| No `.csproj`, only a folder of `.aspx` (Web Site project) | There is no project file to read a 4.x version from | Convert to a Web Application first, or approve a file-by-file page map |
| `.vb` / `.aspx.vb` | This pack's templates are C# | Approve a C# translation step, or stop |
| WinForms (`.Designer.cs` with `System.Windows.Forms`) or WPF (`.xaml`) | This pipeline builds ASP.NET Core screens, not desktop forms | Use a desktop skill later. Do not wrap the form in a website |
| Already SDK-style (`<Project Sdk="Microsoft.NET.Sdk`) | This is not a Framework 4.x rewrite | Do a normal TFM bump, not the 7-phase rewrite |
| WCF `net.tcp`, MSMQ, or duplex (`CallbackContract`) | External clients call the old SOAP contract | Keep the old host, or approve a compatibility layer |
| COM, Office interop, Crystal Reports, ReportViewer | No equivalent we can generate safely | Leave that call in the old app and list it as out of scope |
| AppDomain, .NET Remoting, GAC-only DLL | Those APIs are not in .NET 10 | Ask for a replacement design before coding |
| NuGet package with no `net10.0` / `net8.0` asset | The new project will not build | Name the package and ask for a replacement |
| Shared library still referenced by an app that stays on .NET Framework | A `net10.0` library cannot be referenced by a 4.x app | Target `netstandard2.0` for that library, or upgrade every consumer in this run |

Class libraries, console apps, and Windows Services are not "stop", but they are not websites.
Do not ask the Razor-vs-React question for them. Scaffold the same project kind on `net10.0`
(or `net10.0-windows` for a Windows Service / WinForms host) and keep public class and method names.
