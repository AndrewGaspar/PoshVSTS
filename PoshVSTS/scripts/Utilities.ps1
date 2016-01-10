
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

function DecryptSecureString {
    Param([SecureString]$sstr)
    
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sstr)
    $str = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    
    $str
}

function GetAuth([string]$Instance) {
    $credentials = Get-VstsCredentials $Instance
    
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
