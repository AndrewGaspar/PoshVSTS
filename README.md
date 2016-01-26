# PoshVSTS
A PowerShell module for interacting with Visual Studio Team Services

## Credential Store

Add credentials for a VSTS instance using Set-VstsCredentials. This will set the default
credentials for the VSTS instance. You should be able to user your default user name and
password, but you pay need to generate an application token if your VSTS instance disallows
Basic authentication.

```powershell
GIT F:\Projects\PoshVSO [master ≡]> Set-VstsCredentials andrewgaspar.visualstudio.com andrew.gaspar@outlook.com


    Directory: C:\Users\Andrew\AppData\Roaming\PoshVSTS\Instances


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----        1/18/2016  11:21 PM                andrewgaspar.visualstudio.com

```

## Projects

To get all projects in a VSTS instance:

```powershell
GIT P:\PoshVSO [master]> Get-VstsProject andrewgaspar.visualstudio.com


id          : 1acd195c-b542-44e4-b36a-8b0cb0440e71
name        : Git LIVE!
description : A tool for monitoring GitHub users, repos, and organizations from Windows.
url         : https://andrewgaspar.visualstudio.com/DefaultCollection/_apis/projects/1acd195c-b542-44e4-b36a-8b0cb0440e71
state       : wellFormed
revision    : 358049374

id          : 53d4c59d-b6cd-46e2-b642-af667cf60381
name        : Blog
description : This is my personal website, primarily my blog.
url         : https://andrewgaspar.visualstudio.com/DefaultCollection/_apis/projects/53d4c59d-b6cd-46e2-b642-af667cf60381
state       : wellFormed
revision    : 358049357
```

## Teams

```powershell
GIT F:\Projects\PoshVSO [master ≡]> Get-VstsProjectTeam andrewgaspar.visualstudio.com "Blog"


id          : 8ff104e0-9844-4ead-8ca5-d8251e1d79c1
name        : Blog Team
url         : https://andrewgaspar.visualstudio.com/DefaultCollection/_apis/projects/53d4c59d-b6cd-46e2-b642-af667cf60381/teams/8ff104e0-9844-4ead-8ca5-d8251e1d79c1
description : The default project team.
identityUrl : https://andrewgaspar.vssps.visualstudio.com/_apis/Identities/8ff104e0-9844-4ead-8ca5-d8251e1d79c1
```
