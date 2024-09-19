<#
.SYNOPSIS
Automatically manages the specified Windows service, providing options to ensure it's running or to forcibly restart it.



.DESCRIPTION
This PowerShell script checks the status of a Windows service by its name. If the service is not currently running and the ForceStart parameter is specified, the script will start the service. Regardless of the current state, if the service is running and does not require forceful starting, it will be restarted to ensure it's operating on the latest configuration or to recover from a stalled state.

.PARAMETER ServiceName
Specifies the name of the service(s) to be managed. If not provided, defaults to "BrokerAgent".

.PARAMETER ForceStart
A boolean flag indicating whether to start the service if it's found to be not running. Does not affect running services; running services are always restarted for maintenance or recovery purposes.

.EXAMPLE
PS> .\CheckAndRestartService.ps1 -ServiceName "CustomServiceName" -ForceStart $true

Attempts to start "CustomServiceName" if it's not running, and restarts it if it is running.

.EXAMPLE
PS> .\CheckAndRestartService.ps1 -ForceStart $true

Applies the operation to the "BrokerAgent" service, starting it if not running, or restarting it if already active.

.NOTES
Version:        1.1
Author:         John Li
Last Modified:  April 20, 2024
Remarks:        Updated to include ForceStart functionality for more flexible service management.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ServiceNames = "",

    [Parameter(Mandatory = $false)]
    [int]$Seconds = "60",
    
    [Parameter(Mandatory = $false)]
    [bool]$ForceStart = $false
)

Write-Host "Sleep Time $Seconds seconds."
Start-Sleep -Seconds $Seconds

$ServiceNameArray =$ServiceNames.Split(",")
$serviceNameInvald = $false
$serviceRestartFailed = $false

foreach ($ServiceName in $ServiceNameArray) {
    try {
        $serviceName = $ServiceName.Trim()    
        $service = Get-Service -Name $serviceName -ErrorAction Ignore
        if (-not $service)
        {
            Write-Warning "Can't find the service: '$serviceName'" 
            $serviceNameInvald = $true
            continue
        }
       
        if ($service.Status -ne 'Running') {
            if ($ForceStart) {
                Start-Service -Name $ServiceName
                $service.Refresh()
                if ($service.Status -eq 'Running') {
                    Write-Host "Service '$ServiceName' has been started."
                } else {
                    Write-Warning "Failed to start service '$ServiceName'."
                    $serviceRestartFailed = $true
                }
            } else {
                Write-Warning "Service '$ServiceName' is not running. Use -ForceStart to start it."
                $serviceRestartFailed = $true
            }
        } elseif ($service.Status -eq 'Running') {
            Restart-Service -Name $ServiceName -Force
            $service.Refresh()
            if ($service.Status -eq 'Running') {
                Write-Host "Service '$ServiceName' has been restarted."
            } else {
                Write-Warning "Failed to restart service '$ServiceName'."
                $serviceRestartFailed = $true
            }
        }

    } catch {
        Write-Warning "Service '$ServiceName' is not installed or cannot be accessed. Error: $_"
        $serviceRestartFailed = $true
    }
}

if (-not $serviceNameInvald -and -not $serviceRestartFailed) {
    Write-Output "The command completed successfully."
} else {
    if ($serviceNameInvald) { 
        #Invalid parameters provided to the script.            
        Exit 2
    }
    if ($serviceRestartFailed) {
        #The service could not be started or restarted.
        Exit 11
    }
}
# SIG # Begin signature block
# MIIbqAYJKoZIhvcNAQcCoIIbmTCCG5UCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDR1/gy6YRw0V7g
# LYN8o61XE5MULMOL0SmO4Xm5H/NIgKCCFf0wggL6MIIB4qADAgECAhB6J1wJzTdx
# nUKvHOtdOD3sMA0GCSqGSIb3DQEBCwUAMBUxEzARBgNVBAMMCldFTVNlcnZpY2Uw
# HhcNMjQwOTE5MTUyNTI0WhcNMjkwOTE5MTUzNTI0WjAVMRMwEQYDVQQDDApXRU1T
# ZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuLETAOuekKCk
# +LDaP5N/2URTPryBm+d3q8R9Kq5RD79SKOit0MM6mZU4AxCSxgx/6aBosorU7wXb
# MOB65mK5Jr1O97TebtMHXd4PJJcVn0X0nQDrxkREVfGwIrEGPrmvFDbnkLd6e6kV
# DHulIHl1JwaeE6SGbeUKDeayVYhsnSIjb69EreZG0Jgp6px0vplesDPXYS1ShCA2
# Cue7/F+3O/RjsOOrRL+E96rMrtceyM/0G/BCbQK5THqPB9WY/yIihB1iuMHPqQmA
# fcRGO00hdtDGiinnG8Xbln3qw1HsmgDCkM3HvrJUOyRGuRh6G91sEQcFiH5to16t
# 22fcgz+rvQIDAQABo0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwHQYDVR0OBBYEFIjeB6dlvg6zpSs90mguEGC3gdVyMA0GCSqGSIb3DQEB
# CwUAA4IBAQAT12fQZkg6bw9j9RsMg/k2J9m3dLMQiUItAy0fr5BOBakNZixsnIKv
# 41koQFiy7R0G5OIV1LXdAIr0CsbqHle+4RCokyiAqivKlLUM2/KN+ob1ltBt/Zau
# Gn4KMgHP117RWEiq3p4XVvCSFVf1R8Y5j1CwFZ8xYV4YjzGh+E2rtCVXAVFyezcY
# c8I10r0LwP+kNrp6kk6TR7pgYsu7iCu/d3EY4sPoJosLgbBk0tFrUxn3KLMnV/Cf
# HhOQgac0R6aB6ZKlYhV3Su7YJ7Rm9LcIrTtGj0leG/3+HcFbaZeMfA40gmJvQzpQ
# QjdfBxh3D9lIJSbFgc+utsG7MJFfWXrfMIIGFDCCA/ygAwIBAgIQeiOu2lNplg+R
# yD5c9MfjPzANBgkqhkiG9w0BAQwFADBXMQswCQYDVQQGEwJHQjEYMBYGA1UEChMP
# U2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1YmxpYyBUaW1lIFN0
# YW1waW5nIFJvb3QgUjQ2MB4XDTIxMDMyMjAwMDAwMFoXDTM2MDMyMTIzNTk1OVow
# VTELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UE
# AxMjU2VjdGlnbyBQdWJsaWMgVGltZSBTdGFtcGluZyBDQSBSMzYwggGiMA0GCSqG
# SIb3DQEBAQUAA4IBjwAwggGKAoIBgQDNmNhDQatugivs9jN+JjTkiYzT7yISgFQ+
# 7yavjA6Bg+OiIjPm/N/t3nC7wYUrUlY3mFyI32t2o6Ft3EtxJXCc5MmZQZ8AxCbh
# 5c6WzeJDB9qkQVa46xiYEpc81KnBkAWgsaXnLURoYZzksHIzzCNxtIXnb9njZhol
# Gw9djnjkTdAA83abEOHQ4ujOGIaBhPXG2NdV8TNgFWZ9BojlAvflxNMCOwkCnzlH
# 4oCw5+4v1nssWeN1y4+RlaOywwRMUi54fr2vFsU5QPrgb6tSjvEUh1EC4M29YGy/
# SIYM8ZpHadmVjbi3Pl8hJiTWw9jiCKv31pcAaeijS9fc6R7DgyyLIGflmdQMwrNR
# xCulVq8ZpysiSYNi79tw5RHWZUEhnRfs/hsp/fwkXsynu1jcsUX+HuG8FLa2BNhe
# UPtOcgw+vHJcJ8HnJCrcUWhdFczf8O+pDiyGhVYX+bDDP3GhGS7TmKmGnbZ9N+Mp
# EhWmbiAVPbgkqykSkzyYVr15OApZYK8CAwEAAaOCAVwwggFYMB8GA1UdIwQYMBaA
# FPZ3at0//QET/xahbIICL9AKPRQlMB0GA1UdDgQWBBRfWO1MMXqiYUKNUoC6s2GX
# GaIymzAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUE
# DDAKBggrBgEFBQcDCDARBgNVHSAECjAIMAYGBFUdIAAwTAYDVR0fBEUwQzBBoD+g
# PYY7aHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljVGltZVN0YW1w
# aW5nUm9vdFI0Ni5jcmwwfAYIKwYBBQUHAQEEcDBuMEcGCCsGAQUFBzAChjtodHRw
# Oi8vY3J0LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNUaW1lU3RhbXBpbmdSb290
# UjQ2LnA3YzAjBggrBgEFBQcwAYYXaHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJ
# KoZIhvcNAQEMBQADggIBABLXeyCtDjVYDJ6BHSVY/UwtZ3Svx2ImIfZVVGnGoUaG
# dltoX4hDskBMZx5NY5L6SCcwDMZhHOmbyMhyOVJDwm1yrKYqGDHWzpwVkFJ+996j
# KKAXyIIaUf5JVKjccev3w16mNIUlNTkpJEor7edVJZiRJVCAmWAaHcw9zP0hY3gj
# +fWp8MbOocI9Zn78xvm9XKGBp6rEs9sEiq/pwzvg2/KjXE2yWUQIkms6+yslCRqN
# XPjEnBnxuUB1fm6bPAV+Tsr/Qrd+mOCJemo06ldon4pJFbQd0TQVIMLv5koklInH
# vyaf6vATJP4DfPtKzSBPkKlOtyaFTAjD2Nu+di5hErEVVaMqSVbfPzd6kNXOhYm2
# 3EWm6N2s2ZHCHVhlUgHaC4ACMRCgXjYfQEDtYEK54dUwPJXV7icz0rgCzs9VI29D
# wsjVZFpO4ZIVR33LwXyPDbYFkLqYmgHjR3tKVkhh9qKV2WCmBuC27pIOx6TYvyqi
# YbntinmpOqh/QPAnhDgexKG9GX/n1PggkGi9HCapZp8fRwg8RftwS21Ln61euBG0
# yONM6noD2XQPrFwpm3GcuqJMf0o8LLrFkSLRQNwxPDDkWXhW+gZswbaiie5fd/W2
# ygcto78XCSPfFWveUOSZ5SqK95tBO8aTHmEa4lpJVD7HrTEn9jb1EGvxOb1cnn0C
# MIIGXTCCBMWgAwIBAgIQOlJqLITOVeYdZfzMEtjpiTANBgkqhkiG9w0BAQwFADBV
# MQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQD
# EyNTZWN0aWdvIFB1YmxpYyBUaW1lIFN0YW1waW5nIENBIFIzNjAeFw0yNDAxMTUw
# MDAwMDBaFw0zNTA0MTQyMzU5NTlaMG4xCzAJBgNVBAYTAkdCMRMwEQYDVQQIEwpN
# YW5jaGVzdGVyMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxMDAuBgNVBAMTJ1Nl
# Y3RpZ28gUHVibGljIFRpbWUgU3RhbXBpbmcgU2lnbmVyIFIzNTCCAiIwDQYJKoZI
# hvcNAQEBBQADggIPADCCAgoCggIBAI3RZ/TBSJu9/ThJOk1hgZvD2NxFpWEENo0G
# nuOYloD11BlbmKCGtcY0xiMrsN7LlEgcyoshtP3P2J/vneZhuiMmspY7hk/Q3l0F
# PZPBllo9vwT6GpoNnxXLZz7HU2ITBsTNOs9fhbdAWr/Mm8MNtYov32osvjYYlDNf
# efnBajrQqSV8Wf5ZvbaY5lZhKqQJUaXxpi4TXZKohLgxU7g9RrFd477j7jxilCU2
# ptz+d1OCzNFAsXgyPEM+NEMPUz2q+ktNlxMZXPF9WLIhOhE3E8/oNSJkNTqhcBGs
# bDI/1qCU9fBhuSojZ0u5/1+IjMG6AINyI6XLxM8OAGQmaMB8gs2IZxUTOD7jTFR2
# HE1xoL7qvSO4+JHtvNceHu//dGeVm5Pdkay3Et+YTt9EwAXBsd0PPmC0cuqNJNcO
# I0XnwjE+2+Zk8bauVz5ir7YHz7mlj5Bmf7W8SJ8jQwO2IDoHHFC46ePg+eoNors0
# QrC0PWnOgDeMkW6gmLBtq3CEOSDU8iNicwNsNb7ABz0W1E3qlSw7jTmNoGCKCgVk
# LD2FaMs2qAVVOjuUxvmtWMn1pIFVUvZ1yrPIVbYt1aTld2nrmh544Auh3tgggy/W
# luoLXlHtAJgvFwrVsKXj8ekFt0TmaPL0lHvQEe5jHbufhc05lvCtdwbfBl/2ARST
# uy1s8CgFAgMBAAGjggGOMIIBijAfBgNVHSMEGDAWgBRfWO1MMXqiYUKNUoC6s2GX
# GaIymzAdBgNVHQ4EFgQUaO+kMklptlI4HepDOSz0FGqeDIUwDgYDVR0PAQH/BAQD
# AgbAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwSgYDVR0g
# BEMwQTA1BgwrBgEEAbIxAQIBAwgwJTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0
# aWdvLmNvbS9DUFMwCAYGZ4EMAQQCMEoGA1UdHwRDMEEwP6A9oDuGOWh0dHA6Ly9j
# cmwuc2VjdGlnby5jb20vU2VjdGlnb1B1YmxpY1RpbWVTdGFtcGluZ0NBUjM2LmNy
# bDB6BggrBgEFBQcBAQRuMGwwRQYIKwYBBQUHMAKGOWh0dHA6Ly9jcnQuc2VjdGln
# by5jb20vU2VjdGlnb1B1YmxpY1RpbWVTdGFtcGluZ0NBUjM2LmNydDAjBggrBgEF
# BQcwAYYXaHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggGB
# ALDcLsn6TzZMii/2yU/V7xhPH58Oxr/+EnrZjpIyvYTz2u/zbL+fzB7lbrPml8ER
# ajOVbudan6x08J1RMXD9hByq+yEfpv1G+z2pmnln5XucfA9MfzLMrCArNNMbUjVc
# RcsAr18eeZeloN5V4jwrovDeLOdZl0tB7fOX5F6N2rmXaNTuJR8yS2F+EWaL5VVg
# +RH8FelXtRvVDLJZ5uqSNIckdGa/eUFhtDKTTz9LtOUh46v2JD5Q3nt8mDhAjTKp
# 2fo/KJ6FLWdKAvApGzjpPwDqFeJKf+kJdoBKd2zQuwzk5Wgph9uA46VYK8p/BTJJ
# ahKCuGdyKFIFfEfakC4NXa+vwY4IRp49lzQPLo7WticqMaaqb8hE2QmCFIyLOvWI
# g4837bd+60FcCGbHwmL/g1ObIf0rRS9ceK4DY9rfBnHFH2v1d4hRVvZXyCVlrL7Z
# QuVzjjkLMK9VJlXTVkHpuC8K5S4HHTv2AJx6mOdkMJwS4gLlJ7gXrIVpnxG+aIni
# GDCCBoIwggRqoAMCAQICEDbCsL18Gzrno7PdNsvJdWgwDQYJKoZIhvcNAQEMBQAw
# gYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtK
# ZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYD
# VQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTIx
# MDMyMjAwMDAwMFoXDTM4MDExODIzNTk1OVowVzELMAkGA1UEBhMCR0IxGDAWBgNV
# BAoTD1NlY3RpZ28gTGltaXRlZDEuMCwGA1UEAxMlU2VjdGlnbyBQdWJsaWMgVGlt
# ZSBTdGFtcGluZyBSb290IFI0NjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAIid2LlFZ50d3ei5JoGaVFTAfEkFm8xaFQ/ZlBBEtEFAgXcUmanU5HYsyAhT
# XiDQkiUvpVdYqZ1uYoZEMgtHES1l1Cc6HaqZzEbOOp6YiTx63ywTon434aXVydmh
# x7Dx4IBrAou7hNGsKioIBPy5GMN7KmgYmuu4f92sKKjbxqohUSfjk1mJlAjthgF7
# Hjx4vvyVDQGsd5KarLW5d73E3ThobSkob2SL48LpUR/O627pDchxll+bTSv1gASn
# /hp6IuHJorEu6EopoB1CNFp/+HpTXeNARXUmdRMKbnXWflq+/g36NJXB35ZvxQw6
# zid61qmrlD/IbKJA6COw/8lFSPQwBP1ityZdwuCysCKZ9ZjczMqbUcLFyq6KdOpu
# zVDR3ZUwxDKL1wCAxgL2Mpz7eZbrb/JWXiOcNzDpQsmwGQ6Stw8tTCqPumhLRPb7
# YkzM8/6NnWH3T9ClmcGSF22LEyJYNWCHrQqYubNeKolzqUbCqhSqmr/UdUeb49zY
# Hr7ALL8bAJyPDmubNqMtuaobKASBqP84uhqcRY/pjnYd+V5/dcu9ieERjiRKKsxC
# G1t6tG9oj7liwPddXEcYGOUiWLm742st50jGwTzxbMpepmOP1mLnJskvZaN5e45N
# uzAHteORlsSuDt5t4BBRCJL+5EZnnw0ezntk9R8QJyAkL6/bAgMBAAGjggEWMIIB
# EjAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQU9ndq
# 3T/9ARP/FqFsggIv0Ao9FCUwDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMB
# Af8wEwYDVR0lBAwwCgYIKwYBBQUHAwgwEQYDVR0gBAowCDAGBgRVHSAAMFAGA1Ud
# HwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RS
# U0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDA1BggrBgEFBQcBAQQpMCcwJQYI
# KwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEM
# BQADggIBAA6+ZUHtaES45aHF1BGH5Lc7JYzrftrIF5Ht2PFDxKKFOct/awAEWgHQ
# MVHol9ZLSyd/pYMbaC0IZ+XBW9xhdkkmUV/KbUOiL7g98M/yzRyqUOZ1/IY7Ay0Y
# bMniIibJrPcgFp73WDnRDKtVutShPSZQZAdtFwXnuiWl8eFARK3PmLqEm9UsVX+5
# 5DbVIz33Mbhba0HUTEYv3yJ1fwKGxPBsP/MgTECimh7eXomvMm0/GPxX2uhwCcs/
# YLxDnBdVVlxvDjHjO1cuwbOpkiJGHmLXXVNbsdXUC2xBrq9fLrfe8IBsA4hopwsC
# j8hTuwKXJlSTrZcPRVSccP5i9U28gZ7OMzoJGlxZ5384OKm0r568Mo9TYrqzKeKZ
# gFo0fj2/0iHbj55hc20jfxvK3mQi+H7xpbzxZOFGm/yVQkpo+ffv5gdhp+hv1GDs
# vJOtJinJmgGbBFZIThbqI+MHvAmMmkfb3fTxmSkop2mSJL1Y2x/955S29Gu0gSJI
# kc3z30vU/iXrMpWx2tS7UVfVP+5tKuzGtgkP7d/doqDrLF1u6Ci3TpjAZdeLLlRQ
# Zm867eVeXED58LXd1Dk6UvaAhvmWYXoiLz4JA5gPBcz7J311uahxCweNxE+xxxR3
# kT0WKzASo5G/PyDez6NHdIUKBeE3jDPs2ACc6CkJ1Sji4PKWVT0/MYIFATCCBP0C
# AQEwKTAVMRMwEQYDVQQDDApXRU1TZXJ2aWNlAhB6J1wJzTdxnUKvHOtdOD3sMA0G
# CWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZI
# hvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
# ARUwLwYJKoZIhvcNAQkEMSIEIFqVHgjHJI9bix292ChRCRBbYjCNXneDDF9jAbH5
# DiC3MA0GCSqGSIb3DQEBAQUABIIBACsSOkv8UY96yqEDZ3pEDJXiEvATAEnynY+G
# XJo4h8aOCwFEIMAUhpSkw1c/k/pTt919766liSceebfGnzUmYd6Xsf3q76teOJhL
# SiY1ZWtoP/0uuD4GPLsiZOHLtoeKWjd0+nd0GoP71pE/kddx+7MmIU+s2NzbXJ4v
# Whv8hECb2DpeXIeUj0UQUA9LJHrmGwbEFMeYXhaOv1YUEZMpC9qlXLb9hQVy5Rbu
# HiKiWk/BB5kxfLLUYTHqBNWNhSyAvP5PIUS8kUK/FyDdd+QUBbDhWC/dsld5N1GP
# /1ZLx6j5ibB1wYtsgG8RWfbT1Z2VTlNWMYD0i6DwPcVX8+8B4oGhggMiMIIDHgYJ
# KoZIhvcNAQkGMYIDDzCCAwsCAQEwaTBVMQswCQYDVQQGEwJHQjEYMBYGA1UEChMP
# U2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDEyNTZWN0aWdvIFB1YmxpYyBUaW1lIFN0
# YW1waW5nIENBIFIzNgIQOlJqLITOVeYdZfzMEtjpiTANBglghkgBZQMEAgIFAKB5
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI0MDkx
# OTE3MDEzMVowPwYJKoZIhvcNAQkEMTIEMM65NM8P17e7TsX5iYIibtJh69KsKs70
# kJmpmBRLj/0V05bsnr6MVpNVvSENHyTLDDANBgkqhkiG9w0BAQEFAASCAgBHxv0u
# c5HFN0JwprWcytxlDfqiOy2k3um+tbt28Zun9BImwnAD8jqRdv+ZybQNVMs834lv
# QNNezBG0CeTXjzW/17tnUnjuE64/QuggCjZnim0SAm6iZ/EcqN3Hv0+8BNTINwAW
# OWCdlgJfR+2D/W4l7tGNMGDKBEkIdBE0ecOxl6wHQqOJBkhztiYOXwiI7fJbe9bm
# MEYuZ4jBmgdo6OHp4tfjSULtK/0P0XoIapVtg1VoIj2lbIrGgc9N0t+/P6c0jE7L
# lV9oDahr+va2c2zK7jlquBO4TWzdAt+E/7CXpEgTKISKrP0g602fQiGCXc1eWC3i
# 2cLXVO+DGrx9ztJy2AB5kcG3KvRioUnHPaa9GsRyCSzbggqrF1tS8M78YD6v2sE8
# 1u+d1qzfpvv1C0jbiKbwAMSJG1tyc4MQMqxPdcrx2lrnYSCk2N0C3uFPmP3LAc9N
# djbtru92Vl6BvQoEMPxJYhRQbTjGuopjbyOrtaZpcu/Mc64wLLNLb+4tLv90/hDY
# VSXgGW5yj2Jl0fdi4Xv/ditZoW9wKBtu9ghan0fyW49TYOvYLKTVkCtt/go39T5w
# s7MkWszgUEUSx4/7x6ycV48W8Yj7am28MjLTZVQIBp1dxzHlvz9vvmUZf40iYSs0
# ay5ULXMmMQwd3Yv8KuZR2bYuPaqZ+w9YexN67A==
# SIG # End signature block
