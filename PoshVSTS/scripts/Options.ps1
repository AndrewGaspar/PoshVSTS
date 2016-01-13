function Get-VstsOptions {
    Param(
        [string]$Instance,
        [string]$ApiVersion = "1.0"
    )
    
    (Invoke-VstsOperation $Instance "_apis" $ApiVersion Options).value
}