# Engineering standards

Current technical defaults for Breeze On application work.

## Stack

| Layer | Standard |
| --- | --- |
| UI | Blazor Web App, Interactive Server (global interactivity) |
| Runtime | ASP.NET Core / C# / .NET 10 |
| Auth (ADM today) | ASP.NET Core Identity |
| Database | Azure SQL / SQL Server (T-SQL); see [database.md](database.md) |

## Repository model

- **Multi-repo:** one repository per application or shared concern (e.g. STANDARDS, ADM).
- Do not merge unrelated products into a single app repo.

## Local development

- Solution + `src/<Project>` layout as used in ADM.
- Ignore local databases and secrets; never commit credentials.

## Database

Relational column and SQL script conventions: [database.md](database.md).

## Documentation

Engineering changes that affect how others run or understand the app must update that repo’s README / README_AI per [documentation standards](documentation.md). Cross-cutting or new implemented systems must update STANDARDS `architecture/` in the same change set when applicable.
