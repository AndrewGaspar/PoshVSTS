function Get-VstsProjectTeam {
    [CmdletBinding(DefaultParameterSetName="All")]
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
        [string]$Name,
        [Parameter(
            Mandatory=$True, 
            Position=2,
            ParameterSetName="Id")]
        [guid]$Id,
        [int]$ChunkSize = 100
    )
    
    $team = "$null"
    switch($PSCmdlet.ParameterSetName) {
        Id {
            $team = $id
        }
        Name {
            $team = $name
        }
        All {
            $team = "*"
        }
    }
    
    if(!$team.Contains("*")) {
        Invoke-VstsGetOperation $Instance "_apis/projects/$Project/teams/$team" "2.0-preview"
    } else {
        GetAllPagedValues `
            -Instance $Instance `
            -Path "_apis/projects/$Project/teams" `
            -ApiVersion "2.0-preview" `
            -ChunkSize $ChunkSize |
            ? { $_.Name -like $team }
    }
}