
function BuildUrl {
    Param(
        [string]$Instance,
        [string]$Path,
        [hashtable]$Parameters
    )
    
    $url = "https://$Instance/defaultcollection/$Path"
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

function DecryptSecureString {
    Param([SecureString]$sstr)
    
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sstr)
    $str = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    
    $str
}

function GetAuth([string]$Instance) {
    $credentials = Get-VstsCredentials $Instance
    
    if($null -eq $credentials) {
        Write-Error -Message "No default credentials available for $Instance. Call Set-Credentials to set the credentials."
        return
    }
    
    "Basic $([System.Convert]::ToBase64String(
        [System.Text.Encoding]::UTF8.GetBytes(
            "$($credentials.UserName):$(DecryptSecureString $credentials.Password)")))"
}

function Invoke-VstsOperation {
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
    $auth = GetAuth $Instance -EA Stop
    
    if($Method -eq "Get") {
        Invoke-RestMethod `
            -Uri $url `
            -Method $Method `
            -Headers @{ Authorization = $auth }
    } else {
        Invoke-RestMethod `
            -Uri $url `
            -Method $Method `
            -Body ($Body | ConvertTo-Json -Depth 10 -Compress) `
            -ContentType "application/json" `
            -Headers @{ Authorization = $auth }
    }
}
    
function Invoke-VstsGetOperation {
    Param(
        [string]$Instance,
        [string]$Path,
        [string]$ApiVersion,
        [hashtable]$Parameters = @{}
    )
    
    Invoke-VstsOperation $Instance $Path $ApiVersion Get $Parameters
}

function GetAllPagedValues {
    Param(
        [string]$Instance,
        [string]$Path,
        [string]$ApiVersion,
        [hashtable]$Parameters = @{},
        [int]$ChunkSize = 100
    )
    
    $skip = 0
    
    $Parameters['$top'] = $ChunkSize
    
    do
    {
        $Parameters['$skip'] = $skip
        
        $results = Invoke-VstsGetOperation $Instance $Path $ApiVersion $Parameters
        
        $skip += $results.count;
        
        $results.value
    } while($results.count -eq $ChunkSize);
}
