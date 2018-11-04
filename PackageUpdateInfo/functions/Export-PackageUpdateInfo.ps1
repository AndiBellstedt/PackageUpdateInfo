function Export-PackageUpdateInfo {
    <#
    .SYNOPSIS
        Export-PackageUpdateInfo

    .DESCRIPTION
        Export-PackageUpdateInfo

    .PARAMETER Param1
        Explaination for Param1

    .EXAMPLE
        PS C:\> Export-PackageUpdateInfo

        Example for usage of Export-PackageUpdateInfo
    #>
    [CmdletBinding( SupportsShouldProcess=$true,
                    ConfirmImpact='Medium')]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [PackageUpdate.Info]
        $InputObject,

        [Parameter(Mandatory=$true, Position=0)]
        [String]
        $Path,

        [switch]
        $PassThru
    )
    
    begin {
    }

    process {
        if ($pscmdlet.ShouldProcess("Configuration to $($outputPath)", "Export")) {
            
        }
    }

    end {
    }
}
