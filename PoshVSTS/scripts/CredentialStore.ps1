
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


function Get-VstsCredentials {
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

function Set-VstsCredentials {
    Param(
        [string]$Instance,
        [pscredential]$Credentials)
    
    StoreCredentials $Instance $Credentials
}