# v1.0.6
- Issue #15 fixed (References to old deprecated `REPORT_FUNC` method.)
- Services now support lowercase `init` and `start` methods.
- Controllers alias added for services for usage on client. New template for Client uses "Controllers" name instead of "Services".
- Misc. fixes
- `@/s` require alias for Wally ServerPackages
- `objects` require alias for Objects under Knight
- Knight `ErrorHandler.OnError` passes a table instead of tuple.
    ```luau
	ErrorHandler.OnError:Fire(child.Name, {
		runType = runType,
		isShared = Knight.IsShared,
		child = child,
		trace = trace,
		message = message,
        timestamp = os.time()
	})
    ```
- ReplicatedStorage `ClientLoaded` attribute for Client.