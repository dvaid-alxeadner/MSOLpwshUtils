<#
.SYNOPSIS
This is a script for enabling/disabling/querying MFA in Microsoft Office 365 accounts.

.DESCRIPTION
https://github.com/dvaid-alxeadner/MSOLpwshUtils

.PARAMETER 1
Allows input values "E" for enabling MFA, "D" for disabling MFA, "Q" for querying MFA status for a particular user.

.PARAMETER 2
It is the UPN for the Microsoft Office 365 account in the form: user@domain.com

.EXAMPLE
PS> .\MFAAddRemove E user@domain
.EXAMPLE
PS> .\MFAAddRemove D user@domain
.EXAMPLE
PS> .\MFAAddRemove Q user@domain

.NOTES
@2021

.LINK
github.com/dvaid_alxeadner/MSOLpwshUtils

#>
function MFA
{
    Param ([string]$upn,[string]$op)

    try {
        
        $UserMSO=Get-MsolUser -UserPrincipalName $upn -ErrorAction Stop
        
        if ($UserMSO)
        {
            $objectId=$UserMSO.ObjectID
            if ($op -eq "E")
            {
                Write-Host "Enabling MFA for"$upn" With ObjectID="$objectId

                $authenticationRequirements = New-Object "Microsoft.Online.Administration.StrongAuthenticationRequirement"
                $authenticationRequirements.RelyingParty = "*"
                $authenticationRequirements.State = "Enabled"
                Set-MsolUser -ObjectId $objectId -StrongAuthenticationRequirements $authenticationRequirements
            }
            elseif ($op -eq "D") 
            {
                Write-Host "Disabling MFA for"$upn" With ObjectID="$objectId
                $Sta = @()
                Set-MsolUser -ObjectId $objectId -StrongAuthenticationRequirements $Sta
            }
            elseif ($op -eq "Q")
            {
                Get-MsolUser -ObjectId $objectId | Select-Object @{N="Names"; E={$_.DisplayName -replace ",","-"}},Title,UserPrincipalName,BlockCredential,isLicensed,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}}
            }
            else 
            {
                Write-Host "Invalid Input" 
                exit 
            }
        }    
    }    
    Catch
    {
        Write-Output $_.Exception.GetType().FullName, $_.Exception.Message
        Write-Host "Error please report in https://github.com/dvaid-alxeadner/MSOLpwshUtils" 
        exit 
    }
}

try {
    
    $action=$args[0]
    $target=$args[1]
    
    $arrayUPN=$target.Split(',')

    # Connect To Office (Interactive Login)
    Connect-MsolService -Credential $userCredential

    if ($arrayUPN.count -gt 1)
    {
        foreach ($stringUPN in $arrayUPN)
        {
            MFA $stringUPN $action
        }
    }
    else
    {
        MFA $target $action
    }
}
Catch
{
    Write-Output $_.Exception.GetType().FullName, $_.Exception.Message
    Write-Host "Error please report in https://github.com/dvaid-alxeadner/MSOLpwshUtils" 
    exit 
}