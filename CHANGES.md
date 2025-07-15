# v1.0.6

### 🔄 Licensing

* The framework has been officially **relicensed under "Meta Games LLC"**, replacing the previous "RAMPAGE Interactive" brand, which is now considered deprecated and inactive.

### 🐛 Bug Fixes

* **Issue #15 Resolved**: All remaining references to the outdated `REPORT_FUNC` debugging utility have been removed or refactored.
* **Minor internal cleanup**: Unused variables, obsolete references, and redundant requires were removed for better runtime stability and maintainability.

### ⚙️ Framework Enhancements

* **Lifecycle Method Support**: Both `init` and `start` methods for Services now support **lowercase syntax**, allowing for more flexibility in developer naming conventions.
* **Client-Side Structure Updated**:
  * The **"Services" folder on the client has been renamed to "Controllers"** to better reflect its purpose and distinguish it from server-side services.
  * Services loaded on the client are now also aliased as **Controllers**, supporting better organizational patterns in large-scale projects.
  * You can still use the old "Services" name on the client.

### 📦 Module Resolution

* **New Require Aliases**:
  * `@/s` → Maps to **Wally ServerPackages**, enabling cleaner and centralized module importing.
  * `objects` → Maps to the **Objects directory under Knight**, allowing simpler access to framework-defined objects and utilities.

### ⚠️ Error Handling Improvements
* The `Knight.ErrorHandler.OnError` event now emits a **structured table** instead of a tuple. This change allows for more descriptive and robust error logging.
  **Example:**

  ```lua
  ErrorHandler.OnError:Fire(child.Name, {
      runType = runType,
      isShared = Knight.IsShared,
      child = child,
      trace = trace,
      message = message,
      timestamp = os.time()
  })
  ```

### 🧩 Replication Enhancements

* Added a new **`ClientLoaded` attribute under `ReplicatedStorage`**, used to signal when the client has successfully initialized. This can be leveraged by server scripts for post-initialization logic or gating systems.

### 🛠 Miscellaneous

* Multiple **require/import path adjustments** to improve developer experience and enforce better separation between shared, client, and server modules.
* General **codebase refinements**, including formatting consistency, naming standardization, and performance tweaks.