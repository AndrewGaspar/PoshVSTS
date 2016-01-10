
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
    if(!(Get-Item -EA SilentlyContinue $credentialsPath)) {
        return
    }
    
    $json = Get-Content $credentialsPath | ConvertFrom-Json
    
    $json.Password = ConvertTo-SecureString $json.Password
    
    $json | Add-Member -NotePropertyName Instance -NotePropertyValue $Instance
    
    $json
}

function Remove-VstsCredentials {
    Param(
        [Parameter(
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [string]$Instance)
    
    $credentialsPath = "~\AppData\Roaming\PoshVSTS\Instances\$Instance\credentials.json"
    
    Get-Item -EA SilentlyContinue $credentialsPath | Remove-Item 
}


function Get-VstsCredentials {
    Param([string]$Instance = "*")
    
    ls "~\AppData\Roaming\PoshVSTS\Instances" $Instance | % { RedeemCredentials $_.Name }
}

function Set-VstsCredentials {
    Param(
        [string]$Instance,
        [pscredential]$Credentials)
    
    StoreCredentials $Instance $Credentials
}