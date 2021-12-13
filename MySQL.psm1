Set-StrictMode -Version Latest

$null = [System.Reflection.Assembly]::LoadWithPartialName('MySql.Data')

$pubpath=$PSScriptRoot + "\public\"
$publist=Get-ChildItem -Path $pubpath -Filter "*.ps1" -Name
$prvpath=$PSScriptRoot + "\private\"
$prvlist=Get-ChildItem -Path $prvpath -Filter "*.ps1" -Name

foreach ($func in $publist)
{
    $funcname=$func -replace ".ps1",""
    . ($pubpath + $func)
    Export-ModuleMember -Function $funcname
}


foreach ($func in $prvlist)
{
    . ($prvpath + $func)
    $funcname=$func -replace ".ps1",""
}
