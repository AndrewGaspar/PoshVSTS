
function Get-VstsProject {
    [CmdletBinding(DefaultParameterSetName="Query")]
    Param(
        [Parameter(Position=0, Mandatory=$True)]
        [string]$Instance,
        [Parameter(Mandatory=$True, 
            Position=1,
            ParameterSetName="Instance",
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [string]$Id,
        [Parameter(ParameterSetName="Instance")]
        [switch]$IncludeCapabilities,
        [Parameter(ParameterSetName="Query")]
        [ValidateSet("WellFormed", "CreatePending", "Deleting", "New", "All")]
        [string]$StateFilter = "WellFormed",
        [Parameter(ParameterSetName="Query")]
        [int]$ChunkSize = 10
    )
    
    switch($PSCmdlet.ParameterSetName) {
        Query {
            $Parameters = @{
                stateFilter = $StateFilter
            }
            
            GetAllPagedValues $Instance "projects" "1.0" $Parameters $ChunkSize 
        }
        Instance {
            $Parameters = @{}
            if($IncludeCapabilities) {
                $Parameters["includeCapabilities"] = "true"
            }
            
            InvokeGetOperation $Instance "projects/$Id" "1.0" $Parameters
        }
    }
}

function Set-VstsProject {
    Param(
        [string]$Name,
        [string]$Description,
        [Parameter(Mandatory=$True, Position=0)]
        [string]$Instance,
        [Parameter(Mandatory=$True,
            Position = 1,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [string]$Id
    )
    
    if(!($Name -or $Description)) {
        return;
    }
    
    $body = @{}
    
    if($Name){
        $body["name"] = $Name
    }
    
    if($Description) {
        $body["description"] = $Description
    }
    
    InvokeOperation $Instance "projects/$Id" "2.0-preview" Patch -Body $body
}

function Rename-VstsProject {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$Instance,
        [Parameter(Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [string]$Id,
        [Parameter(Mandatory=$True)]
        [string]$Name
    )
    
    Set-VstsProject $Instance $Id -Name $Name
}

function New-VstsProject {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$Instance,
        [Parameter(Mandatory=$True)]
        [string]$Name,
        [Parameter(Mandatory=$True)]
        [string]$Description,
        [Parameter(Mandatory=$True)]
        [ValidateSet("Git", "Tfvc")]
        [string]$SourceControlType,
        [Parameter(Mandatory=$True)]
        [string]$TemplateTypeId
    )
    
    InvokeOperation $Instance "projects" "2.0-preview" Post -Body (@{
        name = $Name
        description = $Description
        capabilities = @{
            versioncontrol = @{
                sourceControlType = $SourceControlType
            }
            processTemplate = @{
                templateTypeId = $TemplateTypeId
            }
        }
    })
}

function Remove-VstsProject {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$Instance,
        [Parameter(Mandatory=$True, 
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [string]$Id
    )
    
    InvokeOperation $Instance "projects/$Id" "1.0" Delete
}
