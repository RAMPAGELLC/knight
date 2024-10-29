# Getting a service

<figure><img src="../../.gitbook/assets/Getting a service.jpg" alt=""><figcaption></figcaption></figure>

## Getting a service

In Knight, services can be accessed in a few different ways depending on how your configuration is set up. A key setting that impacts how you fetch services is the `CYCLIC_INDEXING_ENABLED` flag, which controls whether cyclic dependencies between services are allowed. By default, this setting is enabled.

## Accessing Services

Services in Knight can be accessed using either the `Knight.Import` method or the newer, more memory-efficient `Knight.GetService` method (introduced in version 0.0.7). These methods allow you to retrieve and interact with other services in your game.

However, if you have `CYCLIC_INDEXING_ENABLED` set to `true` (the default setting), you can also access other services directly by indexing the `Knight.Services` table within a service. This allows services to reference one another cyclically.

### Accessing Services with Cyclic Indexing

When `CYCLIC_INDEXING_ENABLED` is `true`, you can access another service directly from within your current service without worrying about manual importing or memory overhead from excessive service loading. This is useful for cases where services need to call each other's functions during their execution.

Here’s an example of how you can use cyclic indexing to call a function from another service:

```lua
local Service = {}

function Service:Start()
    -- Cyclic indexing allows you to access another service directly
    local result = Service.Services.OtherService:CallFunction()
    warn("Result from OtherService: ", result)
end

return Service
```

In this example:

* `Service.Services.OtherService` refers to another service called `OtherService` Running on the same context level (Server or Client), to reference a shared Service/Object use Service.Shared...
* `CallFunction()` is a method defined within the `OtherService` service.

## How Cyclic Indexing Works

With `CYCLIC_INDEXING_ENABLED` set to `true`, Knight's internal service loader allows services to reference one another via the `Services` table. This is beneficial when services are interdependent, such as when one service needs to trigger an event or call a function in another service.

## Considerations When Using Cyclic Indexing

{% hint style="danger" %}
While cyclic indexing can be convenient, it's important to note that in complex projects, heavy reliance on cyclic dependencies can increase the difficulty of managing your services. This is especially true if the dependency chain grows large. To avoid memory issues and potential bugs, Knight introduced `GetService` as an alternative.



On large experiences such as the Rosource Project, the Emergency Response Series, etc we average around \~3GB Client Memory with Cyclic enabled. Please note this specifically with the large-coldebase with all gameplay features.
{% endhint %}

## Disabling Cyclic Indexing

If you prefer to avoid cyclic dependencies altogether, you can disable cyclic indexing by setting `CYCLIC_INDEXING_ENABLED` to `false` in your `KNIGHT_CONFIG.lua` file. When cyclic indexing is disabled, services must be explicitly retrieved using either `Knight.Import` or `Knight.GetService`, and attempts to access services via cyclic indexing will fail.

Here’s how you disable cyclic indexing:

```lua
return {
    CYCLIC_INDEXING_ENABLED = false
}
```

With cyclic indexing disabled, you would need to retrieve services like this:

```lua
local Knight = {}

function Knight:Start()
    local OtherService = Knight:GetService("OtherService")
    warn(OtherService:CallFunction())
end

return Knight
```

{% hint style="info" %}
#### When cyclic indexing is disabled you will still be able to index the following:

* Player
* Enum
* initStart
* Inited
* KnightCache
* GetService
* Remotes
{% endhint %}

#### Best Practices

* **Use Cyclic Indexing Sparingly**: While convenient, cyclic indexing can lead to tightly coupled services. For better maintainability, consider using `GetService` or `Import` to explicitly manage dependencies.
* **Optimize for Memory Usage**: In large games with many services, consider disabling cyclic indexing and using `GetService` for a more memory-efficient approach.
* **Keep Dependencies Clear**: Regardless of whether cyclic indexing is enabled or disabled, ensure that your services have well-defined responsibilities to avoid confusion and unintended dependencies.

> Article & Art by vq9o
