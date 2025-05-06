# ![51Degrees](https://51degrees.com/DesktopModules/FiftyOne/Distributor/Logo.ashx?utm_source=github&utm_medium=repository&utm_content=home&utm_campaign=c-open-source "Data rewards the curious") **IP Intelligence Data Files**

## Introduction

This repository contains the freely available 'lite' version of the 51Degrees IP Intelligence data file.

The properties available in this file are:

- RegisteredCountry
- RegisteredName
- RegisteredOwner
- More properties are available for free in our [cloud service](https://configure.51degrees.com/), or on a commercial basis on [our website](https://51degrees.com/pricing).

This 'lite' file is built from a subsection of all IPs and is updated less frequently than the paid-for data files.

This repository uses [Git LFS](https://git-lfs.github.com/) rather than storing these large binary files directly.

## Pulling the files

### From Azure

Select and run a script to download files from Azure.

| Script | Language | OS |
| -- | -- | -- |
| `./get-lite-file-from-azure.ps1` | PowerShell | [Windows](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5), [Linux](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.5), [macOS](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos?view=powershell-7.5) |
| `./get-lite-file-from-azure.sh` | Shell | Linux, macOS |

### From LFS

On Linux:

```sh
sudo apt-get install git-lfs
git lfs install
```

Then,  execute:

```sh
git lfs pull
```

## Files

### `51Degrees-LiteV41.ipi`

The 'lite' on-premise IP Intelligence data file.

### `get-lite-file-from-azure.ps1`/`.sh`

Convenience scripts to download (and unpack) data file, stored on Azure Blob Storage.

### `evidence-gen.ps1`

A script to re-/generate the "evidence" files (CSV/YML) with a designated number of random IPv4 and/or IPv6 addresses.

Useful invocations:

```pwsh
    ./evidence-gen.ps1 -v4 10000 -v6 10000 "evidence.yml"
    ./evidence-gen.ps1 -v4 10000 -v6 10000 -csv "evidence.csv"
```

### `evidence.csv`/`.yml`

Pre-generated test files containing 20,000 of random IPs.

- evidence.csv - Each line contains a single IP.
- evidence.yml - A multi-record yaml file where each line contains the HTTP header name and value as the key/value pair. Values may be wrapped in single quotes.
