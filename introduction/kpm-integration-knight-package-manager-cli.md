# KPM Integration: Knight Package Manager CLI

<figure><img src="../.gitbook/assets/kpm.jpg" alt=""><figcaption></figcaption></figure>

## KPM Integration: Knight Package Manager CLI

KPM (Knight Package Manager) is a command-line tool developed in TypeScript and distributed as an npm package (`kpm.client`). Its purpose is to streamline the process of managing Knight packages, such as `Cmdr`, in a structure similar to npm. With KPM, you can install, update, and uninstall Knight packages from your desktop CLI, allowing for easy management of game development dependencies.

This article will guide you through setting up KPM and provide example usage for managing packages within your Knight framework projects.

## Installing KPM

To get started with KPM, you’ll need to install it globally via npm. Ensure you have Node.js and npm installed on your system.

```bash
npm install -g kpm.client
```

Once installed, you can access KPM through your command line using the `kpm` command.

## Example Usage of KPM

Let’s look at a basic example of using KPM in your desktop CLI.

```bash
C:\Users\administrator> kpm
  _  ______  __  __        _ _            _
 | |/ /  _ \|  \/  |   ___| (_) ___ _ __ | |_
 | ' /| |_) | |\/| |  / __| | |/ _ \ '_ \| __|
 | . \|  __/| |  | | | (__| | |  __/ | | | |_
 |_|\_\_|   |_|  |_|  \___|_|_|\___|_| |_|\__|

Copyright (c) 2024 RAMPAGE Interactive.
Written by vq9o and Contributor(s).

Knight Package Manager CLI
```

### Basic Commands

Here are some of the most commonly used commands in KPM, along with example usage.

#### **1. Installing a Package**

To install a Knight package (such as `Cmdr`), use the `install` command. You can specify the package and an optional version:

```bash
kpm install cmdr
```

This will install the latest version of the `Cmdr` package. You can also specify a version:

```bash
kpm install cmdr 1.2.3
```

This installs version `1.2.3` of the `Cmdr` package.

#### **2. Uninstalling a Package**

To uninstall a package, use the `uninstall` command:

```bash
kpm uninstall cmdr
```

This removes the `Cmdr` package from your Knight project.

#### **3. Updating Packages**

To update all installed packages to their latest versions, use the `update` command:

```bash
kpm update
```

You can also update a specific package by specifying its name:

```bash
kpm update cmdr
```

This updates only the `Cmdr` package to the latest version.

#### **4. Checking for Updates**

To check if a specific package has a new version available without installing the update, use the `check-update` command:

```bash
kpm check-update cmdr
```

This will display information about whether a new version of the `Cmdr` package is available.

#### **5. Outputting the Manifest of a Package**

To view the manifest (for example a NPM package.json) of a specific package, use the `output-manifest` command:

```bash
kpm output-manifest cmdr
```

This will print the package’s manifest to the console, showing details such as the version, dependencies, and other metadata.

#### **6. Publishing Packages**

KPM also allows you to publish packages. To open the KPM publish form in your default browser, use the `publish` command:

```bash
kpm publish
```

This will redirect you to the form where you can submit your package to the KPM repository.

#### **7. Package Count**

To get a count of all installed packages, use the `count` command:

```bash
kpm count
```

This will display the total number of packages installed in your project.

### Advanced Commands

KPM offers several advanced commands to help you further customize and manage your environment.

#### **1. Setting the Installation Path**

By default, KPM installs packages in the current running directory, but you can change this location using the `set-path` command:

```bash
kpm set-path C:/MyGame/KnightPackages
```

This sets the new path where packages will be installed.

To verify the current path, use:

```bash
kpm get-path
```

#### **2. Unsafe Mode**

KPM has a feature called "unsafe mode," which allows you to enable or disable certain operations that may pose risks to your game’s stability. You can toggle unsafe mode using the `unsafemode` command:

```bash
kpm unsafemode enable
```

To disable it:

```bash
kpm unsafemode disable
```

#### **3. Reinstalling KPM Client**

If you need to reinstall or update the KPM client to the latest version, you can use the `npm` command:

```bash
kpm npm
```

This command will uninstall and reinstall KPM to ensure you have the latest version of the CLI.

#### **4. Logging In**

To access certain features, such as downloading private packages, you need to be logged in. Use the `login` command to log in and save your authentication key:

```bash
bkpm login
```

Follow the prompts to log in securely.

## Example Workflow

Here’s an example of a typical workflow using KPM in a project:

1.  **Install Cmdr**:

    ```bash
    kpm install cmdr
    ```
2.  **Set a Custom Installation Path**:

    ```bash
    kpm set-path C:/MyGame/KnightPackages
    ```
3.  **Check for Updates for Cmdr**:

    ```bash
    kpm check-update cmdr
    ```
4.  **Update All Packages**:

    ```bash
    kpm update
    ```
5.  **Output Manifest for Cmdr**:

    ```bash
    kpm output-manifest cmdr
    ```
6.  **Log in to KPM**:

    ```bash
    kpm login
    ```

This workflow allows you to efficiently manage the packages used in your Knight framework project without leaving your desktop CLI.
