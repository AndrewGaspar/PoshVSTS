
. "$PSScriptRoot\scripts\Utilities.ps1"
. "$PSScriptRoot\scripts\CredentialStore.ps1"
. "$PSScriptRoot\scripts\Projects.ps1"
. "$PSScriptRoot\scripts\Teams.ps1"
. "$PSScriptRoot\scripts\Options.ps1"
. "$PSScriptRoot\scripts\WorkItems.ps1"

Export-ModuleMember "*-Vsts*"

. "$PSScriptRoot\scripts\ArgumentCompletion.ps1"