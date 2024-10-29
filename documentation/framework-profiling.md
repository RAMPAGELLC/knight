# Framework Profiling

<figure><img src="../.gitbook/assets/Framework Profiling.jpg" alt=""><figcaption></figcaption></figure>

{% hint style="danger" %}
Article is not completed, and KnightProfiler is unreleased software currently under going rigorous internal testing.
{% endhint %}

## Framework Profiling

Profiling a complex framework like Knight can be challenging due to the way the framework initializes and manages its components. Traditional profiling methods may not provide the granularity or context needed to fully understand the performance characteristics of services and operations within the framework. However, there is a dedicated tool that makes this process much easier: `KnightProfiler`.

In this article, we’ll discuss the difficulties of profiling the Knight framework and introduce `KnightProfiler` as the solution to gather meaningful performance insights.

## The Challenge of Profiling Knight

The Knight framework is designed to initialize services, shared modules, and core components dynamically, based on the context in which it operates (server or client). Due to this dynamic nature, traditional profiling tools may struggle to pinpoint bottlenecks, particularly during the initialization phase.

### For example:

* **Service Initialization**: Services in Knight may depend on other services or shared modules, causing their initialization to be asynchronous and conditional.
* **Dynamic Imports**: The use of dynamic imports and cyclic dependencies makes it harder for profiling tools to capture performance metrics accurately at the exact moment they are required.
* **Contextual Execution**: The behavior of the framework may vary depending on whether it is running on the client or server, adding an additional layer of complexity to profiling efforts.

## Introducing KnightProfiler

To overcome these challenges, you can use **KnightProfiler**, a purpose-built tool designed to profile the Knight framework with minimal setup. `KnightProfiler` captures performance data during initialization, service execution, and other critical operations within the framework, providing you with the insights necessary to optimize your game.

You can get `KnightProfiler` at the following repository:

* **KnightProfiler**: [https://github.com/RAMPAGELLC/KnightProfiler](https://github.com/RAMPAGELLC/KnightProfiler)

### Features of KnightProfiler

* **Detailed Service Profiling**: Track the initialization time and execution performance of individual services within the Knight framework.
* **Granular Module Profiling**: Monitor how long specific shared modules or components take to load and execute, helping identify performance bottlenecks.
* **Contextualized Reports**: Get profiling data that is contextualized based on whether it’s running in the client, server, or shared environments, allowing you to optimize based on the specific context of your game.
* **Low Overhead**: Designed to work seamlessly with Knight without adding significant performance overhead, ensuring that your profiling data is accurate and your game remains performant.

### Installing and Using KnightProfiler

1. **Clone or Download KnightProfiler**: Start by cloning or downloading the repository from GitHub.
   * GitHub Repo: [KnightProfiler](https://github.com/RAMPAGELLC/KnightProfiler)
2. **Integrate with Knight**: Follow the instructions in the repository to integrate KnightProfiler into your existing Knight framework setup. The profiler is designed to hook into Knight’s initialization and service management process with minimal changes to your codebase.
3. **Run Your Game**: Once KnightProfiler is integrated, run your game as you normally would. KnightProfiler will automatically begin capturing performance data during the game’s initialization and as services execute.
4. **Analyze the Data**: After you’ve run your game with KnightProfiler, review the performance reports it generates. You can use this data to:
   * Identify services that are taking too long to initialize.
   * Track down shared modules that may be causing bottlenecks.
   * Analyze how different services interact with each other and pinpoint any inefficiencies.

### Example Usage of KnightProfiler

Here’s a quick example of how to set up and use KnightProfiler after integrating it into your game:

<pre class="language-lua"><code class="lang-lua">-- Copyright (c) 2024 RAMPAGE Interactive
-- Written by vq9o

local ReplicatedStorage= game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local KnightProfiler= require(ReplicatedStorage.Packages.KnightProfiler)
local Knight = require(ReplicatedStorage.Packages.Knight)

-- Start profiling services
KnightProfiler:Start()

-- Initialize Knight Framework
local KnightInstance, KnightAPI = Knight.Core:Init()

task.wait(10)

-- Stop profiling after initialization is complete and 10 seconds has passed
KnightProfiler:Stop()

-- Output the profiling report to the console to save it for later analysis
local UUID: string = HttpService:GenerateGUID(false)

KnightProfiler:GenerateReport(UUID)

repeat
<strong>    task.wait()
</strong><strong>until KnightProfiler:ReportIsCompleted(UUID)
</strong>
-- Force any and all connected clients to quit game.
KnightProfiler:Quit()
</code></pre>

### Best Practices for Profiling with KnightProfiler

* **Profile Early and Often**: Start profiling your game as early as possible during development. This will help you catch performance issues before they become ingrained in your game’s architecture.
* **Focus on Bottlenecks**: Use KnightProfiler to focus on specific areas of your game that are underperforming, such as services that are slow to start or shared modules that are being loaded too frequently.
* **Adjust Based on Context**: Pay close attention to the differences in performance between the client and server environments, as bottlenecks may occur in one environment but not the other.
