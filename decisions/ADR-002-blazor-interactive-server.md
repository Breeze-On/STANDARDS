# ADR-002: Blazor Interactive Server

Status: Accepted

## Context

Breeze On application UIs are built with ASP.NET Core and C#. The administration application (ADM) and the Shared UI gallery need interactive Blazor components with server-side .NET access to data and Identity. A single interactivity model keeps product apps and the design-system gallery aligned.

## Decision

Use **Blazor Web App** with **Interactive Server** as the standard UI hosting/interactivity model (global interactivity where the app configures it). Runtime target is **.NET 10**. Shared UI (`BreezeOn.UI`) is a Razor Class Library consumed by Interactive Server hosts.

## Consequences

- Product pages run on the server with SignalR circuits; full server .NET APIs and Identity cookie flows remain straightforward.
- Hosted apps require an always-on ASP.NET Core process (e.g. Azure App Service for ADM DEV).
- The Shared UI gallery uses the same Interactive Server pattern for local preview without a database.
- Product apps should not adopt a different Blazor hosting model without an ADR update or supersession.
