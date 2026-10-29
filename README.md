# Flowboard Mobile - Multiplatform Application

Flutter application of Flowboard (Performily). It has the same features and design as the
native Android application.

## Architecture

DDD + Clean Architecture. Each bounded context lives in `lib/features/<context>` with four layers:
`presentation`, `application`, `domain` and `infrastructure`. Shared code lives in `lib/core`.

State is handled with `ChangeNotifier` view models, dependencies with `get_it` and the network with `http`.

## Bounded contexts

workspace, attendance, request, benefits, payroll, wellbeing, dashboard.

## Branches

`main`, `develop` and one feature branch per bounded context (for example `workspace`).
