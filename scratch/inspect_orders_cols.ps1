$connString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"

function Query-Sql ($query) {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
    try {
        $connection.Open()
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataset) | Out-Null
        $connection.Close()
        return $dataset.Tables[0]
    } catch {
        Write-Host "DB Error: $_"
    }
}

Write-Host "--- ORDERS TABLE ---"
Query-Sql "SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Orders'" | ft -AutoSize

Write-Host "--- ORDER ITEMS TABLE ---"
Query-Sql "SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'OrderItems'" | ft -AutoSize
