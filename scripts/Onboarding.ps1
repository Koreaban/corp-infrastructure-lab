# ==============================================================================
# Script: Onboarding.ps1
# Description: Automates the creation of AD users, assigns them to OUs and Groups
# Domain: corp.local
# ==============================================================================

Import-Module ActiveDirectory

Write-Host "=== STARTING USER ONBOARDING AUTOMATION ===" -ForegroundColor Cyan

# Define basic variables
$Domain = "corp.local"
$DomainPath = "DC=corp,DC=local"
$DefaultPassword = ConvertTo-SecureString "Welcome2026!!" -AsPlainText -Force

# Array of users to onboard based on the lab topology
$Users = @(
    @{ FirstName="Oleksandr"; LastName="Teslenko";   Sam="o.teslenko";   Dept="IT";    Group="GG_IT" },
    @{ FirstName="Lukas";     LastName="Mueller";    Sam="l.mueller";    Dept="IT";    Group="GG_IT" },
    @{ FirstName="Hannah";    LastName="Schmidt";    Sam="h.schmidt";    Dept="HR";    Group="GG_HR" },
    @{ FirstName="Sofia";     LastName="Kovalenko";  Sam="s.kovalenko";  Dept="Sales"; Group="GG_Sales" },
    @{ FirstName="Leon";      LastName="Fischer";    Sam="l.fischer";    Dept="IT";    Group="GG_IT" },
    @{ FirstName="Emma";      LastName="Weber";      Sam="e.weber";      Dept="HR";    Group="GG_HR" },
    @{ FirstName="Maximilian";LastName="Wagner";     Sam="m.wagner";     Dept="Sales"; Group="GG_Sales" },
    @{ FirstName="Anna";      LastName="Shevchenko"; Sam="a.shevchenko"; Dept="Sales"; Group="GG_Sales" },
    @{ FirstName="Felix";     LastName="Becker";     Sam="f.becker";     Dept="IT";    Group="GG_IT" },
    @{ FirstName="Mia";       LastName="Hoffmann";   Sam="m.hoffmann";   Dept="HR";    Group="GG_HR" }
)

foreach ($User in $Users) {
    $FullName = "$($User.FirstName) $($User.LastName)"
    $UPN = "$($User.Sam)@$Domain"
    $OUPath = "OU=$($User.Dept),OU=Company,$DomainPath"
    
    # Check if the user already exists in Active Directory
    if (Get-ADUser -Filter "SamAccountName -eq '$($User.Sam)'" -ErrorAction SilentlyContinue) {
        Write-Host "[SKIP] User $($User.Sam) ($FullName) already exists in AD." -ForegroundColor Yellow
    } else {
        try {
            # 1. Create the AD User
            New-ADUser -Name $FullName -GivenName $User.FirstName -Surname $User.LastName `
                       -SamAccountName $User.Sam -UserPrincipalName $UPN `
                       -AccountPassword $DefaultPassword -Enabled $true `
                       -Department $User.Dept -Path $OUPath

            # 2. Add the User to their respective Security Group
            Add-ADGroupMember -Identity $User.Group -Members $User.Sam
            
            Write-Host "[SUCCESS] Created $($User.Sam) | Dept: $($User.Dept) | Group: $($User.Group)" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] Failed to create $($User.Sam): $_" -ForegroundColor Red
        }
    }
}

Write-Host "=== ONBOARDING COMPLETED ===" -ForegroundColor Cyan