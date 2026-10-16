# Parity contract (what "the same" means)

The new .NET 10 module must be recognizable as the same backend and the same screens.
"The same" does **not** mean the old `.csproj` still says `v4.8`, and it does **not** mean
`HttpContext.Current` still exists. Those APIs do not run on .NET 10.

"The same" means the names and the visible behavior below are copied, not redesigned.

## Controllers and actions

For every MVC or Web API controller in the scoped module:

| Keep this | Example |
|---|---|
| Controller class name | `OrdersController` stays `OrdersController` |
| Action method name | `Details` stays `Details` |
| HTTP verb | a `[HttpPost]` action stays POST |
| URL | `/Orders/Details/{id}` stays `/Orders/Details/{id}` unless the old route was different; then keep the old route |
| Parameters that the screen or client sends | `id`, `CustomerName` stay the same names |
| Return fields | JSON property names and form field names stay the same |

You may change the base class from `System.Web.Mvc.Controller` to `Microsoft.AspNetCore.Mvc.Controller`.
You may change `ActionResult` to `IActionResult`. You may add `async` when the method does I/O.
You may not rename the class or the method while doing that.

## Views (the visual screen)

For every view in the scoped module, the new Razor view must show the same:

- page title and headings
- labels
- input `name` attributes (`CustomerName`, not `customer_name`)
- table column headers
- button text
- links the user clicks to reach another action
- validation messages the old page showed

The shared layout is part of the screen. Copy the navbar title, each menu link, and the footer text from `_Layout` (or the master page) into `parity-map.md`. Use the words found in that repo. A page that matches the form fields and drops the menu is not done. Mark a chrome row out of scope only when the human says so in the map.

The layout stylesheet is part of the screen too. If the legacy layout links a stylesheet, or renders one with `Styles.Render` or a bundle, every checked page must link a stylesheet that the running app returns as HTTP 200 with a non-empty body. The check uses the href on the rendered page. It does not look for one CSS file name.

## WebForms

WebForms pages do not have controllers. Treat each `.aspx` as one screen:

- The new MVC controller name comes from the page name: `Orders.aspx` → `OrdersController`.
- Each postback that the user can trigger (Save button, grid command) becomes an action whose name is the button or command name.
- Every input, column, and message on the `.aspx` is listed in `parity-map.md` and must appear on the new view.
- A human must click the old page and the new page at Gate 4. A passing test is not that click test.

## Code-behind and services

Business rules move into a service class, but the controller action still exists and still calls that rule.
Do not delete an action because "the service does it now."

## What you must write before coding

`parity-map.md`, from `agent-config/templates/parity-map.md`, with one row per action, one row per visible field, and one row per layout title, menu link, and footer line. Every row has the page URL where that text must be visible.
Phase 6 fetches those URLs from the running new app and fails if any required text is missing. Matching the Razor source is not enough.
