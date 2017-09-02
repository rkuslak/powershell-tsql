# SQL Helper Functions
# BSDLicense.txt:
## Copyright 2017 Ronald Kuslak
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
## 1. Redistributions of source code must retain the above copyright notice,
##    this list of conditions and the following disclaimer.
## 
## 2. Redistributions in binary form must reproduce the above copyright notice,
##    this list of conditions and the following disclaimer in the documentation
##    and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.

function OpenSQLConnection([string]$serverName, [string]$user, [string]$password, [string]$db = $null)
{
    $sql = New-Object System.Data.SqlClient.SqlConnection
    $con  = New-Object System.Data.SqlClient.SqlConnectionStringBuilder

    $con.Add("Server", $serverName)
    $con.Add("user", $user)
    $con.Add("password", $password)

    if ($db -ne $null)
    {
        $con.Add("Initial Catalog", $db)
    }

    $sql.ConnectionString = $con.ConnectionString

    $sql.Open()

    return $sql

}

# TODO: Function to break into batches and execute?
function ExecuteQuery(
    [System.Data.SqlClient.SqlConnection]$sqlConnection,
    [string]$query,
    $params = @{}
    )
{
    $cmd = $sqlConnection.CreateCommand()
    $cmd.CommandText = $query

    # Add keys (if any) to the query
    foreach ($key in $params.Keys)
    {
        [void]$cmd.Parameters.AddWithValue("@$($key)", $params[$key])
    }

    [System.Data.DataTable]$returnTable = New-Object System.Data.DataTable
    $returnTable.Load( $cmd.ExecuteReader() )

    return $returnTable
}

function ExecuteNonQuery(
    [System.Data.SqlClient.SqlConnection]$sqlConnection,
    [string]$query,
    $args= @{}
    )
{
    $cmd = $sqlConnection.CreateCommand()
    $cmd.CommandText = $query

    [int]$rows = -1

    # Add keys (if any) to the query
    foreach ($key in $params.Keys)
    {
        [void]$cmd.Parameters.AddWithValue("@$($key)", $params[$key])
    }

    $rows = $cmd.ExecuteNonQuery()

    Write-Host("{0} rows affected." -f $rows)
    return $rows
}