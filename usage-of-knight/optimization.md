# Optimization

## Profiling

Profiling the framework is quite difficult due to how initializing the framework operates, a way to profile is by using KnightProfiler! You can get KnightProfiler at [https://github.com/RAMPAGELLC/KnightProfiler](https://github.com/RAMPAGELLC/KnightProfiler).

## High-memory

How this framework was originally created was your able to index other objects without the need of manually requiring, due to this feature this can cause **high-memory of \~4GB** on large experiences.&#x20;

To combat this issue we recommend disabling `CYCLIC_INDEXING_ENABLED`, please note `CYCLIC_INDEXING_ENABLED` is in beta. Ensure you modify `KEEP_SHARED_ON_CYCLIC_DISABLE` config as well if you want to keep Knight.Shared.
