#The script join Azure File Share to ADDS

Start-Transcript -Path C:\temp\log01.txt -Append -Force
# Change the execution policy to unblock importing AzFilesHybrid.psm1 module
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
Install-Module -Name PowerShellGet -Force
Install-Module -Name AzureAD -Force
Import-Module AzureAD

#Update-Module -Name PowerShellGet -Force

# Navigate to where AzFilesHybrid is unzipped and stored and run to copy the files into your path
#Latest version https://github.com/Azure-Samples/azure-files-samples/releases

cd C:\temp\AzFilesHybrid 
$ScriptToRun= "C:\temp\AzFilesHybrid\CopyToPSPath.ps1"
& $ScriptToRun


# Import AzFilesHybrid module
Import-Module -Name AzFilesHybrid        

#Login with an Azure AD credential that has either storage account owner or contributer Azure role assignment

Connect-AzAccount -TenantId 09fcfac3-02be-48a4-a365-d1d7b42d2c3e

# Define parameters, $StorageAccountName currently has a maximum limit of 15 characters
#$SubscriptionId = "<your-subscription-id-here>"
$ResourceGroupName = "AVD-RG"
$StorageAccountName = "avdfsl799944"
$DomainAccountType = "ComputerAccount" # Default is set as ComputerAccount. ComputerAccount|ServiceLogonAccount
# If you don't provide the OU name as an input parameter, the AD identity that represents the storage account is created under the root directory.
$OuDistinguishedName = "OU=AVD,OU=Servers,OU=Cirrus,DC=p4d,DC=sis,DC=com"
# Specify the encryption agorithm used for Kerberos authentication. Default is configured as "'RC4','AES256'" which supports both 'RC4' and 'AES256' encryption. "<AES256|RC4|AES256,RC4>"
$EncryptionType = "AES256,RC4"

# Select the target subscription for the current session
#Select-AzSubscription -SubscriptionId $SubscriptionId 

# Register the target storage account with your active directory environment under the target OU (for example: specify the OU with Name as "UserAccounts" or DistinguishedName as "OU=UserAccounts,DC=CONTOSO,DC=COM"). 
# You can use to this PowerShell cmdlet: Get-ADOrganizationalUnit to find the Name and DistinguishedName of your target OU. If you are using the OU Name, specify it with -OrganizationalUnitName as shown below. If you are using the OU DistinguishedName, you can set it with -OrganizationalUnitDistinguishedName. You can choose to provide one of the two names to specify the target OU.
# You can choose to create the identity that represents the storage account as either a Service Logon Account or Computer Account (default parameter value), depends on the AD permission you have and preference. 
# Run Get-Help Join-AzStorageAccountForAuth for more details on this cmdlet.

Join-AzStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -StorageAccountName $StorageAccountName `
        -DomainAccountType $DomainAccountType `
        -OrganizationalUnitDistinguishedName $OuDistinguishedName `
        -EncryptionType $EncryptionType

#Run the command below if you want to enable AES 256 authentication. If you plan to use RC4, you can skip this step.
Update-AzStorageAccountAuthForAES256 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName

#You can run the Debug-AzStorageAccountAuth cmdlet to conduct a set of basic checks on your AD configuration with the logged on AD user. This cmdlet is supported on AzFilesHybrid v0.1.2+ version. For more details on the checks performed in this cmdlet, see Azure Files Windows troubleshooting guide.
Debug-AzStorageAccountAuth -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -Verbose

Stop-Transcript