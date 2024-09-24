param(
    [Parameter(Mandatory = $True)]
    [string]$PathScriptToSign
)

$PathCertToUse = "Cert:\CurrentUser\My\" + (Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Where{ $_.Subject -eq "CN=WemService" }).Thumbprint

if(Test-Path $PathScrigitptToSign)
{
  Write-Output "Le script $PathScriptToSign va être signé avec le certificat ($PathCertToUse)"
  $DataCertToUse = Get-Item -Path $PathCertToUse
  Set-AuthenticodeSignature -FilePath $PathScriptToSign -Certificate $DataCertToUse -TimestampServer "http://timestamp.comodoca.com/authenticode"
}