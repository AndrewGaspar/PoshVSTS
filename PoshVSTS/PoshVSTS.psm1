
function BuildUrl {
    Param(
        [string]$Instance,
        [string]$Path,
        [hashtable]$Parameters
    )
    
    $url = "https://$Instance/defaultcollection/_apis/$Path"
    if($Parameters.Count -gt 0) {
        $url += "?"
        $url += ($Parameters.Keys | % { "$_=$($Parameters[$_])" }) -join "&"
    }
    
    $url
}

function MakeDirIfNotExists($path) {
    $dir = Get-Item -ErrorAction SilentlyContinue $path
    if($null -eq $dir) {
        mkdir $path
    } else {
        $dir
    }
}

function StoreCredentials {
    Param(
        [string]$Instance,
        [PSCredential]$Credentials)
    
    $path = "~\AppData\Roaming\PoshVSTS\Instances\$Instance"   
    
    MakeDirIfNotExists $path
    
    $storage = New-Object PSCustomObject -Property @{
        UserName = $Credentials.UserName
        Password = ConvertFrom-SecureString $Credentials.Password
    }
    
    $storage | ConvertTo-Json > "$path\credentials.json"
}

function RedeemCredentials {
    Param([string]$Instance)
    
    $credentialsPath = "~\AppData\Roaming\PoshVSTS\Instances\$Instance\credentials.json"
    if($null -eq (Get-Item -EA SilentlyContinue $credentialsPath)) {
        return $null
    }
    
    $json = Get-Content $credentialsPath | ConvertFrom-Json
    
    $json.Password = ConvertTo-SecureString $json.Password
    
    $json
}

function Clear-VstsCredentials {
    Param([string]$Instance)
    
    $credentialsPath = "~\AppData\Roaming\PoshVSTS\Instances\$Instance\credentials.json"
    
    Get-Item -EA SilentlyContinue $credentialsPath | Remove-Item 
}

function DecryptSecureString {
    Param([SecureString]$sstr)
    
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sstr)
    $str = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    
    $str
}

function GetVstsCredentials {
    Param([string]$Instance)
    
    $storedCredentials = RedeemCredentials $Instance
    
    if($storedCredentials) {
        $storedCredentials
    } else {
        $credentials = Get-Credential
        
        StoreCredentials $Instance $credentials
        
        $credentials
    }
}

function GetAuth([string]$Instance) {
    $credentials = GetVstsCredentials $Instance
    
    "Basic $([System.Convert]::ToBase64String(
        [System.Text.Encoding]::UTF8.GetBytes(
            "$($credentials.UserName):$(DecryptSecureString $credentials.Password)")))"
}

function InvokeOperation {
    Param(
        [string]$Instance,
        [string]$Path,
        [string]$ApiVersion,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method,
        [hashtable]$Parameters = @{},
        [hashtable]$Body = [hashtable]@{} 
    )
    
    $Parameters['api-version'] = $ApiVersion
    
    $url = BuildUrl $Instance $Path $Parameters
    
    if($Method -eq "Get") {
        Invoke-RestMethod `
            -Uri $url `
            -Method $Method `
            -Headers @{ Authorization = GetAuth $Instance }
    } else {
        Invoke-RestMethod `
            -Uri $url `
            -Method $Method `
            -Body ($Body | ConvertTo-Json -Depth 10 -Compress) `
            -ContentType "application/json" `
            -Headers @{ Authorization = GetAuth $Instance }
    }
}
    
function InvokeGetOperation {
    Param(
        [string]$Instance,
        [string]$Path,
        [string]$ApiVersion,
        [hashtable]$Parameters = @{}
    )
    
    InvokeOperation $Instance $Path $ApiVersion Get $Parameters
}

function GetAllPagedValues {
    Param(
        [string]$Instance,
        [string]$Path,
        [string]$ApiVersion,
        [hashtable]$Parameters = @{},
        [int]$ChunkSize = 10
    )
    
    $skip = 0
    
    $Parameters['`$top'] = $ChunkSize
    
    do
    {
        $Parameters['`$skip'] = $skip
        
        $results = InvokeGetOperation $Instance $Path $ApiVersion $Parameters
        
        $skip += $results.count;
        
        $results.value
    } while($results.count -eq $ChunkSize);
}
    
function Get-VstsProject {
    [CmdletBinding(DefaultParameterSetName="Query")]
    Param(
        [Parameter(Position=0, Mandatory=$True)]
        [string]$Instance,
        [Parameter(Mandatory=$True, 
            Position=1,
            ParameterSetName="Instance",
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [string]$Id,
        [Parameter(ParameterSetName="Instance")]
        [switch]$IncludeCapabilities,
        [Parameter(ParameterSetName="Query")]
        [ValidateSet("WellFormed", "CreatePending", "Deleting", "New", "All")]
        [string]$StateFilter = "WellFormed",
        [Parameter(ParameterSetName="Query")]
        [int]$ChunkSize = 10
    )
    
    switch($PSCmdlet.ParameterSetName) {
        Query {
            $Parameters = @{
                stateFilter = $StateFilter
            }
            
            GetAllPagedValues $Instance "projects" "1.0" $Parameters $ChunkSize 
        }
        Instance {
            $Parameters = @{}
            if($IncludeCapabilities) {
                $Parameters["includeCapabilities"] = "true"
            }
            
            InvokeGetOperation $Instance "projects/$Id" "1.0" $Parameters
        }
    }
}

function Set-VstsProject {
    Param(
        [string]$Name,
        [string]$Description,
        [Parameter(Mandatory=$True, Position=0)]
        [string]$Instance,
        [Parameter(Mandatory=$True,
            Position = 1,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [string]$Id
    )
    
    if(!($Name -or $Description)) {
        return;
    }
    
    $body = @{}
    
    if($Name){
        $body["name"] = $Name
    }
    
    if($Description) {
        $body["description"] = $Description
    }
    
    InvokeOperation $Instance "projects/$Id" "2.0-preview" Patch -Body $body
}

function Rename-VstsProject {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$Instance,
        [Parameter(Mandatory=$True, 
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [string]$Id,
        [Parameter(Mandatory=$True)]
        [string]$Name
    )
    
    Set-VstsProject $Instance $Id -Name $Name
}

function New-VstsProject {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$Instance,
        [Parameter(Mandatory=$True)]
        [string]$Name,
        [Parameter(Mandatory=$True)]
        [string]$Description,
        [Parameter(Mandatory=$True)]
        [ValidateSet("Git", "Tfvc")]
        [string]$SourceControlType,
        [Parameter(Mandatory=$True)]
        [string]$TemplateTypeId
    )
    
    InvokeOperation $Instance "projects" "2.0-preview" Post -Body (@{
        name = $Name
        description = $Description
        capabilities = @{
            versioncontrol = @{
                sourceControlType = $SourceControlType
            }
            processTemplate = @{
                templateTypeId = $TemplateTypeId
            }
        }
    })
}

function Remove-VstsProject {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$Instance,
        [Parameter(Mandatory=$True, 
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [string]$Id
    )
    
    InvokeOperation $Instance "projects/$Id" "1.0" Delete
}

function CompleteVstsProjectId {
    param($commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters)
        
    if($fakeBoundParameters.Instance) {
        Get-VstsProject $fakeBoundParameters.Instance | % { $_.id } | ? { $_ -like "$wordToComplete*" }
    }
}

Register-ArgumentCompleter `
    -CommandName @(Get-Command "*-VstsProject") `
    -ParameterName Id `
    -ScriptBlock $function:CompleteVstsProjectId
