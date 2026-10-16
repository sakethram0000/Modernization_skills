# Parity map (`parity-map.md`)

Produced in Phase 4. Phase 5 must follow these names. Phase 6 compares the code to this map.

## Module
[Name of the scoped module]

## Project type
[MVC / Web API / WebForms / class library / console / Windows Service]

## Target
`net10.0`

## Controllers and actions

One row per public action. Copy names from the old code. Do not invent friendlier names.

| Old file | Old type | Action | Verb | Old URL or page | New file | New action | New URL |
|---|---|---|---|---|---|---|---|
| `Controllers/OrdersController.cs` | MVC | `Index` | GET | `/Orders` | `Controllers/OrdersController.cs` | `Index` | `/Orders` |
| `Controllers/OrdersController.cs` | MVC | `Details` | GET | `/Orders/Details/{id}` | `Controllers/OrdersController.cs` | `Details` | `/Orders/Details/{id}` |
| `Controllers/OrdersController.cs` | MVC | `Create` | POST | `/Orders/Create` | `Controllers/OrdersController.cs` | `Create` | `/Orders/Create` |

WebForms: put the `.aspx` path in "Old file", the postback button name in "Action", and the new controller action you will create.

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
[Fields or actions you will not copy in this run, and why]
