$connString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"
$scriptDir = $PSScriptRoot

$files = @(
    "sp_Seller_UpdateOrderStatus.sql",
    "sp_seller_coupons.sql",
    "sp_seller_misc.sql"
)

$connection = New-Object System.Data.SqlClient.SqlConnection($connString)
$connection.Open()

foreach ($file in $files) {
    $path = Join-Path $scriptDir $file
    if (-not (Test-Path $path)) {
        Write-Warning "Skip missing: $file"
        continue
    }
    $raw = Get-Content -Raw -Path $path
    $blocks = $raw -split "(?mi)^\s*GO\s*$"
    foreach ($block in $blocks) {
        $sql = $block.Trim()
        if ($sql.Length -eq 0) { continue }
        $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $connection)
        $cmd.CommandTimeout = 300
        $cmd.ExecuteNonQuery() | Out-Null
    }
    Write-Host "Deployed: $file"
}

$connection.Close()
Write-Host "Seller stored procedures deployed."
