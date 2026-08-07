# Hello World test program

## Requirements
- donnet SDK ``winget install Microsoft.DotNet.SDK``

## Publish

This publishing should be run on the DC and released to the shares for the site

```
dotnet publish -c Release -o \\dc01\sites\HelloWorld
```