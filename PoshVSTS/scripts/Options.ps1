function Get-VstsOption {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$Instance,
        [string]$Area = "*",
        [string]$ResourceName = "*",
        [string]$ApiVersion = "1.0"
    )
    
    (Invoke-VstsOperation $Instance "_apis" $ApiVersion Options).value | 
        Where-Object { ($_.area -like $Area) -and ($_.resourceName -like $ResourceName) }
}

function Get-VstsArea {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$Instance,
        [string]$Area = "*",
        [string]$ApiVersion = "1.0")
        
    Get-VstsOption $Instance $Area | Select-Object -Property Area -Unique
}