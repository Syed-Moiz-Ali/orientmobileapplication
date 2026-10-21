# Supervisor login — focused characterization plan (staff-local)

> Phase-2b note. The supervisor screen lives at
> `apps/staff_app/lib/features/supervisor/presentation/supervisor_login_view.dart`
> and imports `staff_app` localizations, so its widget tests CANNOT live in
> `packages/shared_auth/test/` (which has no access to the staff app). Write
> these tests under `apps/staff_app/test/` once app-level tests exist. Do NOT
> modify the screen to make it testable — logic under test must not change.

## Harness (copy the shared_auth 2b approach)

- `ProviderScope` overriding `authRepositoryProvider` with a controllable fake
  and `tokenStorageProvider` with an in-memory fake; real `AuthNotifier`
  logic, fake only at the use-case boundary.
- `MaterialApp` with `debugShowCheckedModeBanner: false`, the staff
  localizations delegate + `SharedAuthLocalizations.delegate` + the global
  Material/Widgets/Cupertino delegates, `supportedLocales` en/ar, and the
  staff theme.
- Real fonts via `FontLoader` from the SDK MaterialIcons path in `setUpAll`
  (never file I/O inside a test body).
- One RTL case: locale `ar` + global delegates.

## What to assert (current behavior — redesign must preserve unless phase 9
says otherwise)

1. **Empty validation:** empty username or empty password shows
   `supervisorEnterCredentials` (or the hardcoded
   `'Enter username and password'` fallback — record which one renders).
2. **Busy state:** while the login future pends, CTA shows spinner + is
   disabled; double-tap submits exactly once (assert the repo call count).
3. **Field-vs-form routing (DEFECT — preserve, do not fix here):** backend
   failures render the RAW `e.message` string (`_error` passed straight
   through). Characterize the raw text rendering; phase 9 replaces it with
   `mapAuthError` copy via new ARB keys.
4. **Hardcoded `??` fallbacks (DEFECT — preserve, do not fix here):** title,
   subtitle, appName, labels render the inline English literals when staff
   keys are absent. Assert the literal text so the redesign is forced to keep
   equivalent copy via shared_auth keys (phase 9), not silently drop it.
5. **Forgot path:** the forgot link pushes `/forgot-password`.
6. **Success:** a successful login authenticates (role/token persisted) —
   assert `authNotifierProvider` becomes `AuthAuthenticated` exactly once.
7. **Retry/clear:** editing either field clears `_error` (notice slot empties).

## Defects the redesign must fix (phase 9, new ARB keys — no renames)

- Raw `e.message` → `mapAuthError` copy.
- Hardcoded `??` English fallbacks → shared_auth keys.
