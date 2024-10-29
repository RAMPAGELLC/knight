# What are folders

<figure><img src="../../.gitbook/assets/What are folders.jpg" alt=""><figcaption></figcaption></figure>

## What are folders?

Folders contain Services, Objects, etc you may create within your codebase. Everything within the folders will be automatically loaded on game start.

{% hint style="info" %}
Parent **ModuleScript** is loaded, **it's descendants does not**. You can have a infinite amount of folders.\*
{% endhint %}

## Where are they located?

There is 3 locations where the folders are located.

### The Server

This is located in `root/ServerStorage/Knight`

### The Client

This is located in `root/PlayerScripts/StarterPlayerScripts/Knight`

### The Shared

This is located in `root/ReplicatedStorage/Knight`

## How to use?

In this screenshot this is the default layout for **0.0.3,** you can create new folders and delete them as you please.

![](<../../.gitbook/assets/image (3).png>)

Services folders are used to contain services. Go here to learn about here;

{% content-ref url="what-are-services.md" %}
[what-are-services.md](what-are-services.md)
{% endcontent-ref %}

You can create as much folders as you please such as a Objects folder, asset folder, etc. Or even folders under folders. There is no limit & it can be indexed the same.

```lua
Knight.MyCustomFolder.AnotherCoolFolder.AndAnother.CoolModule.bar()
```

## How you utilize folders and stylize is up to you!

<figure><img src="../../.gitbook/assets/image (2).png" alt=""><figcaption><p>Style example</p></figcaption></figure>

> Article & Art by vq9o
