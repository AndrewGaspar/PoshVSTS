Register-ArgumentCompleter `
    -CommandName @(Get-Command "*-Vsts*") `
    -ParameterName Instance `
    -ScriptBlock {
        param($commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters)
            
        Get-ChildItem "~\AppData\Roaming\PoshVSTS\Instances" "$wordToComplete*" | % {
            $_.Name
        }
    }

Register-ArgumentCompleter `
    -CommandName @(Get-Command "*-VstsProject") `
    -ParameterName Id `
    -ScriptBlock {
        param($commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters)
            
        if($fakeBoundParameters.Instance) {
            Get-VstsProject $fakeBoundParameters.Instance | % { $_.id } | ? { $_ -like "$wordToComplete*" }
        }
    }