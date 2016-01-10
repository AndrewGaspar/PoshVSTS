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

function GetFakeProject($fakeBoundParameters) {
    if($fakeBoundParameters.ProjectId) {
        return $fakeBoundParameters.ProjectId
    } elseif($fakeBoundParameters.ProjectName) {
        return $fakeBoundParameters.ProjectName
    }
}

function CompleteTeamName {
    param($commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters)
        
    if($fakeBoundParameters.Instance) {
        & {
            if($fakeBoundParameters.ProjectName) {
                Get-VstsProjectTeam $fakeBoundParameters.Instance $fakeBoundParameters.ProjectName -ChunkSize 1000
            } elseif($fakeBoundParameters.ProjectId) {
                Get-VstsProjectTeam $fakeBoundParameters.Instance $fakeBoundParameters.ProjectId -ChunkSize 1000
            }
        } | % { $_.name } |
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
    -ParameterName ProjectId `
    -ScriptBlock $function:CompleteProjectId
    
Register-ArgumentCompleter `
    -CommandName @(Get-Command "*-VstsProjectTeam") `
    -ParameterName Name `
    -ScriptBlock $function:CompleteTeamName
    