try {
    
    $action=$args[0]
    $target=$args[1]
    
    # Connect To Office (Interactive Login)
    Connect-MsolService -Credential $userCredential

    $UserMSO=Get-MsolUser -UserPrincipalName $target -ErrorAction Stop
    
    if ($UserMSO)
    {
        $objectId=$UserMSO.ObjectID
        if ($action -eq "E")
        {
            Write-Host "Enabling MFA for"$target" With ObjectID="$objectId

            $authenticationRequirements = New-Object "Microsoft.Online.Administration.StrongAuthenticationRequirement"
            $authenticationRequirements.RelyingParty = "*"
            $authenticationRequirements.State = "Enabled"
            Set-MsolUser -ObjectId $objectId -StrongAuthenticationRequirements $authenticationRequirements
        }
        elseif ($action -eq "D") 
        {
            Write-Host "Disabling MFA for"$target" With ObjectID="$objectId
            $Sta = @()
            Set-MsolUser -ObjectId $objectId -StrongAuthenticationRequirements $Sta
        }
        elseif ($action -eq "Q")
        {
            Get-MsolUser -ObjectId $objectId | Select-Object @{N="Names"; E={$_.DisplayName -replace ",","-"}},Title,UserPrincipalName,BlockCredential,isLicensed,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}}
        }
        else {
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