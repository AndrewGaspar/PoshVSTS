function Get-VstsProjectTeam {
    [CmdletBinding(DefaultParameterSetName="Name")]
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]$Instance,
        [Parameter(
            Mandatory=$True, 
            Position=1)]
        [Alias("ProjectName")]
        [Alias("ProjectId")]
        [string]$Project,
        [Parameter(
            Position=2,
            ParameterSetName="Name")]
        [string]$Name = "*",
        [Parameter(
            Position=2,
            ParameterSetName="Id")]
        [guid]$Id,
        [int]$ChunkSize = 100
    )
    
    $team = "*"
    switch($PSCmdlet.ParameterSetName) {
        Id {
            $team = $Id
        }
        Name {
            $team = $Name
        }
    }
    
    if(!$team.Contains("*")) {
        Invoke-VstsGetOperation $Instance "_apis/projects/$Project/teams/$team" "2.0-preview"
    } else {
        Invoke-VstsGetAllOperation `
            -Instance $Instance `
            -Path "_apis/projects/$Project/teams" `
            -ApiVersion "2.0-preview" `
            -ChunkSize $ChunkSize |
            ? { $_.Name -like $team }
    }
}

function Get-VstsProjectTeamMember {
    [CmdletBinding(DefaultParameterSetName="Name")]
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]$Instance,
        [Parameter(
            Mandatory=$True, 
            Position=1)]
        [Alias("ProjectName")]
        [Alias("ProjectId")]
        [string]$Project,
        [Parameter(
            Mandatory=$True, 
            Position=2,
            ParameterSetName="Name")]
        [Alias("TeamName")]
        [Alias("TeamId")]
        [string]$Team,
        [int]$ChunkSize = 100
    )
    
    Invoke-VstsGetAllOperation `
        -Instance $Instance `
        -Path "_apis/projects/$Project/teams/$Team/members" `
        -ApiVersion "1.0" `
        -ChunkSize $ChunkSize
}