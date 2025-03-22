```diff
- Deprecated 'Import()'
+ 'Service.GetMemoryUsageMB()'
+ 'Service.GetService()' improved to get Shared Services. i.e: Knight:GetService("Shared/Foo")
+ New custom require() method to require/import existing Knight services
+ _G.Knight API can now be disabled
+ New sentry integration example in Knight Config
+ REPORT_FUNC functionality fixed
```