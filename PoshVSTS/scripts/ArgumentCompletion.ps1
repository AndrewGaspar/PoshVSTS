Register-ArgumentCompleter `
    -CommandName @(Get-Command "*-Vsts*") `
    -ParameterName Instance `
    -ScriptBlock {
        param($commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters)
            
        Get-VstsCredentials "$wordToComplete*" | % {
            $_.Instance
        }
    }
    
function CompleteProjectId {
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
    -ScriptBlock $function:CompleteProjectId
    
Register-ArgumentCompleter `
    -CommandName @(Get-Command "*-Vsts*") `
    -ParameterName ProjectId `
    -ScriptBlock $function:CompleteProjectId
    
