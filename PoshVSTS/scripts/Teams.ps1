function Get-VstsProjectTeam {
    [CmdletBinding(DefaultParameterSetName="ProjectName_All")]
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]$Instance,
        [Parameter(
            Mandatory=$True, 
            Position=1,
            ParameterSetName="ProjectId_Id")]
        [Parameter(
            Mandatory=$True, 
            Position=1,
            ParameterSetName="ProjectId_Name")]
        [Parameter(
            Mandatory=$True, 
            Position=1,
            ParameterSetName="ProjectId_All")]
        [guid]$ProjectId,
        [Parameter(
            Mandatory=$True, 
            Position=1,
            ParameterSetName="ProjectName_Id")]
        [Parameter(
            Mandatory=$True, 
            Position=1,
            ParameterSetName="ProjectName_Name")]
        [Parameter(
            Mandatory=$True, 
            Position=1,
            ParameterSetName="ProjectName_All")]
        [string]$ProjectName,
        [Parameter(
            Mandatory=$True, 
            Position=2,
            ParameterSetName="ProjectId_Id")]
        [Parameter(
            Mandatory=$True, 
            Position=2,
            ParameterSetName="ProjectName_Id")]
        [guid]$Id,
        [Parameter(
            Mandatory=$True, 
            Position=2,
            ParameterSetName="ProjectId_Name")]
        [Parameter(
            Mandatory=$True, 
            Position=2,
            ParameterSetName="ProjectName_Name")]
        [string]$Name,
        [Parameter(ParameterSetName="ProjectId_All")]
        [Parameter(ParameterSetName="ProjectName_All")]
        [int]$ChunkSize = 100
    )
    
    $project = ""
    switch -wildcard ($PSCmdlet.ParameterSetName) {
        ProjectId* {
            $project = [string]$ProjectId
        }
        ProjectName* {
            $project = $ProjectName
        }
    }
    
    $team = $null
    switch -wildcard ($PSCmdlet.ParameterSetName) {
        *Id {
            $team = $id
        }
        *Name {
            $team = $name
        }
        *All {
            $team = $null
        }
    }
    
    if($team) {
        Invoke-VstsGetOperation $Instance "_apis/projects/$project/teams/$team" "2.0-preview"
    } else {
        GetAllPagedValues $Instance "_apis/projects/$project/teams" "2.0-preview" -ChunkSize $ChunkSize
    }
}