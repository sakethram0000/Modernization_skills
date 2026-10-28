# Parity map (`parity-map.md`)

Produced in Phase 4. Phase 5 must follow these names. Phase 6 compares the code to this map.

Scope: [module | whole application]

## Module
[Name of the scoped module, or the application name in whole-application scope]

## Project type
[MVC / Web API / WebForms / class library / console / Windows Service]

## Target
`net10.0`

## Controllers and actions

One row per public action. Copy names from the old code. Do not invent friendlier names.
`Old file` is the path of the legacy file relative to `runs/<RepoName>/legacy` (or to the project folder inside it). `New file` is the path relative to the new web project. `compare-parity.ps1` finds both files by these paths, so two controllers with the same file name in different folders stay separate.

In whole-application scope, repeat this table under one `###` heading per domain, starting with the shared foundation. Keep the same column headers in every copy.

| Old file | Old type | Action | Verb | Old URL or page | New file | New action | New URL |
|---|---|---|---|---|---|---|---|
| `Controllers/OrdersController.cs` | MVC | `Index` | GET | `/Orders` | `Controllers/OrdersController.cs` | `Index` | `/Orders` |
| `Controllers/OrdersController.cs` | MVC | `Details` | GET | `/Orders/Details/{id}` | `Controllers/OrdersController.cs` | `Details` | `/Orders/Details/{id}` |
| `Controllers/Api/OrdersController.cs` | Web API | `GetOrders` | GET | `/api/orders` | `Controllers/Api/OrdersController.cs` | `GetOrders` | `/api/orders` |

WebForms: put the `.aspx` path in "Old file", the postback button name in "Action", and the new controller action you will create. WCF/ASMX: put the `.svc` or `.asmx` path in "Old file" and the operation name in "Action".

## Shared chrome

Copy these from this repo's layout or master page. Leave the example rows out of a real map.

| Location | Kind | Text that must appear | Page URL |
|---|---|---|---|
| Layout navbar | title | Application name from the layout | `/Home` |
| Layout navbar | link | Menu link text from the layout | `/Home` |
| Layout footer | footer | Footer text from the layout | `/Home` |

## Screen fields

One row per label, input, column, or button a user can see. `Page URL` is where the rendered check looks.

| Screen | Old control | Kind | Text that must appear | Page URL |
|---|---|---|---|---|
| Example Index | create link | link | Create New | `/Items` |
| Example Index | column | column | Name | `/Items` |

## Out of scope on purpose

One row per legacy file or action this run does not copy. `compare-parity.ps1` reads this table. A legacy action with no row here and no row in the controllers table fails the check. Use `*` in `Action` to exclude a whole file. Every row is repeated in `plan.md` open questions and approved at Gate 3.

| Old file | Action | Reason |
|---|---|---|
| `Controllers/ReportsController.cs` | `*` | Calls Crystal Reports (stop list). Approved at Gate 3. |
