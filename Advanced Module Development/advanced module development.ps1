# Failsafe
break

# 1) Go Chrissy!
# 2) Go Chrissy!

# Importing dbatools so it all will work
#Import-Module dbatools
#. .\importinternals.ps1

 #----------------------------------------------------------------------------# 
 #                3) Drowning users in a sea of blood ... not                 # 
 #----------------------------------------------------------------------------# 

# This is going to be bloody
throw "Some error happened"

# This is ... not going to be bloody. But bloody useles for scripting!
try { Write-Warning "Some error happened" }
catch { "Error reaction incoming ... not!"}

# Make it optional
try { throw "Some error happened" }
catch {
    if ($ThrowExceptions) { throw }
    else { Write-Warning $_ }
}
# Opt in
$ThrowExceptions = $true

#####
# Works, but messy

# Solution
$EnableException = $false
Stop-Function -Message "Some error happened"
$EnableException = $true
Stop-Function -Message "Some error happened"

#####
# Demo function
function Get-Test {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $true)]
        [int[]]
        $Numbers,
        [switch]$Foo,
        [switch]$Bar,
        [switch]$EnableException
    )
    begin {
        if ($Foo) {
            Stop-Function -Message "Failing as ordered to"
            return
        }
    }
    process {
        if (Test-FunctionInterrupt) { return }

        foreach ($number in $Numbers) {
            if (($number -eq 2) -and ($Bar)) {
                Stop-Function -Message "Failing on $number as ordered to" -Continue
            }
            $number
        }
    }
}
# No errors wanted
1..3 | Get-Test
# Kill it in begin
1..3 | Get-Test -Foo
# Need more blood
1..3 | Get-Test -Foo -EnableException
# Don't waste it!
try { 1..3 | Get-Test -Foo -EnableException }
catch { "Something broke" }

# Killing in process
1..3 | Get-Test -Bar
1..3 | Get-Test -Bar -EnableException


 #----------------------------------------------------------------------------# 
 #                              4) Configuration                              # 
 #----------------------------------------------------------------------------# 

<#
Basic Issue:Growing option Complexity as command meta-level rises
functionA calls functionB calls functionC calls functionD
- Pass through all parameters?
--> Either provide incredibly complex parameters or choose for the user.
--> Not every choice is right for everybody
- How do you control behavior that doesn't have a command?

--> Need for options separate from commands
#>

# PSReadline has options in dedicated command
Get-PSReadlineOption

<#
Issue: The more options, the less usable a command with parameters for each of them

Solution:
- Option as parameter value, not parameter
#>

Get-DbaConfig

<#
To note:
- Supports option documentation
- Supports input validation
- Supports reacting to setting changes
#>

$paramSetDbaConfig = @{
	FullName    = 'example.setting'
	Value	    = "foo"
	Initialize  = $true
	Validation  = 'string'
	Handler	    = { Write-Host ("Received: {0}" -f $args[0]) }
	Description = "An example setting"
}

Set-DbaConfig @paramSetDbaConfig
Get-DbaConfig 'example.setting'
Set-DbaConfig 'example.setting' "Bar"

Get-DbaConfigValue 'example.setting'

<#
Notes on implementation:
- Available in all runspaaces
- Scales well
- Easy to split configuration definition in to logic groups
#>

<#
Additional features:
- Settings can be persisted per user or per machine
- Can be controlled via GPO/DSC/SCCM
#>


 #----------------------------------------------------------------------------# 
 #                                 5) Logging                                 # 
 #----------------------------------------------------------------------------# 

# Dbatools logs quite a bit
Get-DbaConfigValue -FullName 'path.dbatoolslogpath' | Invoke-Item

<#
Challenges:
- Performance
- Size
- Usability & integration
- Access conflicts
#>

# Usability: Building on the known
#---------------------------------

# Bad
Write-Verbose -Message "Something"

# Good
Write-Message -Level Verbose "Something"


# Performance
#------------

Get-Runspace | ft -AutoSize

# Avoid duplication through C# static management
Get-DbaRunspace

# Script doing the actual logging
code "D:\Code\Github\dbatools\internal\scripts\logfilescript.ps1"


# Size
#-----

Get-DbaConfig logging.*
# Integrated rotate


# Access Conflicts
#-----------------

<#
- One writing thread per process
- Output files named for computer and process ID
#>


# The Other Things
#-----------------

# Forensics!
Get-DbatoolsLog
Write-Message -Level Verbose -Message "Something"


 #----------------------------------------------------------------------------# 
 #                       6) DbaInstance Parameter class                       # 
 #----------------------------------------------------------------------------# 

<#
Original Situation:
- Accept anything, then interpret
- Some contributors / team members would just assume string
- Non-uniform validations
--> Unmanaged madness
#>

<#
Challenge:
- Uniform user experience on input
- Validation overhead
- Converting input from multiple sources
- Passing through live connections
- Keeping it usable for average contributors!!
#>

<#
Answer: Parameter Classes
#>
[DbaInstance]"foo"
[DbaInstance]"foo\bar"
[DbaInstance]"Server=foo\bar;"
[DbaInstance]"(localdb)\foo"
[DbaInstance]([System.Net.DNS]::GetHostEntry("localhost"))
[DbaInstance](Get-ADComputer "Odin")
[DbaInstance](Connect-DbaInstance -SqlInstance localhost)
[DbaInstance]"foo bar"
[DbaInstance]"foo\select"

<#
- Conversion/interpretation as parameter binding
- Pass through original input
- Validation as parameter binding

All the contributors need to do is replace [string] or [object] with [DbaInstance]

Additional benefit:
- Scales exquisitely well: 30 Minutes of work had 380 commands accept localdb
  as input and work correctly against it.
#>


 #----------------------------------------------------------------------------# 
 #                        7) Import Sequence & Tuning                         # 
 #----------------------------------------------------------------------------# 

# Guide through structure

<#
- Parallel import of
-- Functions
-- Libraries
-- Configurations

- Off-Load of
-- Tab Completion

- Measuring each step
#>

[SqlCollaborative.Dbatools.dbaSystem.DebugHost]::ImportTime

<#
Import Options
- Dot Sourcing (Import Speed)
- Copy DLL files before import (To support update function on legacy systems without Side-by-Side)
- Always Compile (Compile library on import; For devs)
- Serial Import (Slower import, less resource spike)
#>