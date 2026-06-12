# ![51Degrees](https://51degrees.com/DesktopModules/FiftyOne/Distributor/Logo.ashx?utm_source=github&utm_medium=repository&utm_content=home&utm_campaign=c-open-source "Data rewards the curious") **IP Intelligence Data Files**

## Introduction

This repo allows to obtain data needed to run IP Intelligence examples:
- evidence files with lists of random IP addresses needed for some examples
- scripts to generate lists of random IP addresses like the above
- scripts to download 'Lite' IP Intelligence data file
- translation files to support translation engine and examples

## Download Lite data file

The Lite data file is too large to commit to this repository, so one of the
scripts below downloads it from 51Degrees storage instead:

| Script | Language | OS |
| -- | -- | -- |
| `./get-lite-file-from-azure.ps1` | PowerShell | [Windows](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5), [Linux](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.5), [macOS](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos?view=powershell-7.5) |
| `./get-lite-file-from-azure.sh` | Shell | Linux, macOS |

Run the script from this directory, because the examples and tests look for
the file here:

```pwsh
cd ip-intelligence-data
./get-lite-file-from-azure.ps1
```

The script downloads the archive as `51Degrees-LiteV41.ipi.gz` (about 230 MB),
prints its MD5 hash and unpacks it to `51Degrees-LiteV41.ipi` (about 460 MB)
in the directory it is run from. If the archive is already present the
download is skipped and the existing archive is unpacked again. Pass `-Force`
(PowerShell) or `-f` (shell) to download a fresh copy, for example when a new
monthly data file has been published. The shell script needs `curl`, `gunzip`
and `md5sum` (`md5` on macOS) to be available.


## Files

### `51Degrees-IPIV4AsnIpiV41.ipi`

The on-premise IP Intelligence data file for Asn properties.

The [properties](https://51degrees.me/developers/property-dictionary?item=Asn%7CAll) available in this file are:

- Asn
- AsnName

More properties are available as part of the Enterprise data file - [contact us](https://51degrees.com/contact-us).

This file is updated monthly.

### `51Degrees-LiteV41.ipi`

The 'lite' on-premise IP Intelligence data file.

The properties available in this file are:

- RegisteredCountry
- RegisteredName
- RegisteredOwner

More properties are available as part of the Enterprise data file - [contact us](https://51degrees.com/contact-us).

This 'lite' file is built from a subsection of all IPs and is updated less frequently than the Enterprise IPI data file.

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

## Translation

Folder containing yaml files for translation of country names into several target languages. This data is used in examples and by the translation engine.

### Folder structure
|--Translations
| |--Translation Source (e.g. "OSM")
| | |-- Translation File (e.g. "countries.fr_FR.yml")

Each translation file contains key-value pairs of "English country name: country name in target language".
