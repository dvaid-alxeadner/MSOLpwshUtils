try {
    
    # Connect To Office (Interactive Login)
    Connect-MsolService -Credential $userCredential
    # Export users to CVS File
    Get-MsolUser -all | Select-Object @{N="Names"; E={$_.DisplayName -replace ",","-"}},Title,UserPrincipalName,BlockCredential,isLicensed,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | Export-csv -path "MFA.csv" -NoTypeInformation -Encoding UTF8 

}
Catch
{
    Write-Output $_.Exception.GetType().FullName, $_.Exception.Message
    Write-Host "Error contact dmejia@postobon.com.co" 
    exit 
}