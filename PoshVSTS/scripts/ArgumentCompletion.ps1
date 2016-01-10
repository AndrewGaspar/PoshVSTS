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

function CompleteProjectName {
    param($commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters)
        
    if($fakeBoundParameters.Instance) {
        Get-VstsProject $fakeBoundParameters.Instance | % { $_.name } | ? { $_ -like "$wordToComplete*" }
    }
}

function CompleteTeamName {
    param($commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters)
        
    if($fakeBoundParameters.Instance -and $fakeBoundParameters.Project) {
        Get-VstsProjectTeam `
         -Instance $fakeBoundParameters.Instance `
         -Project $fakeBoundParameters.Project `
         -ChunkSize 1000 |
            % { $_.name } |
            ? { $_ -like "$wordToComplete*" } |
            % { if($_.Contains(" ")) { "`"$_`"" } else { $_ } }
    }
}

Register-ArgumentCompleter `
    -CommandName @(Get-Command "*-VstsProject") `
    -ParameterName Id `
    -ScriptBlock $function:CompleteProjectId
    
Register-ArgumentCompleter `
    -CommandName @(Get-Command "*-Vsts*") `
    -ParameterName Project `
    -ScriptBlock $function:CompleteProjectName
    
Register-ArgumentCompleter `
    -CommandName @(Get-Command "*-VstsProjectTeam") `
    -ParameterName Name `
    -ScriptBlock $function:CompleteTeamName
    