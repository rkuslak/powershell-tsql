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

#<#
#.Synopsis
#	Function to execute query SQL command batch
#.Description
#	Execute query SQL command batch, and return a DataTable object of the results to the caller.
#.Parameter ServerName
#   Name (and instance if needed) for SQL Server to connect to:
#.Parameter Username
#   Username to use to connect; if none provided, integrated security will
#   be assumed:
#.Parameter Password
#   Password for connection
#.Parameter Database
#   Database name to use as "default" connection
#.Example
#	$ret = Get-SqlConnection $sqlConnection "Server\Instance" sa "SecurePassword" "Adventureworks2000"
#   Get-Query $sql "SELECT 'Foo', 'Bar'" | Format-Table
##>
function Get-SqlConnection {
    [cmdletBinding()]
    param(
        [string]$ServerName,
        [string]$Username = $null,
        [string]$Password = $null,
        [string]$Database = $null
    )

    $sql = New-Object System.Data.SqlClient.SqlConnection
    $con  = New-Object System.Data.SqlClient.SqlConnectionStringBuilder

    $con.Add("Server", $ServerName)

    if ($null -ne $Username -and $null -ne $Password) {
        $con.Add("user", $Username)
        $con.Add("password", $Password)
    } else {
        $con.Add('Integrated Security', 'True')
    }

    if ($null -ne $db) {
        $con.Add("Initial Catalog", $db)
    }

    $sql.ConnectionString = $con.ConnectionString
    $sql.Open()

    return $sql
}

#<#
#.Synopsis
#	Function to execute query SQL command batch
#.Description
#	Execute query SQL command batch, and return a DataTable object of the results to the caller.
#.Parameter sqlConnection
#    System.Data.SqlClient.SqlConnection object against which to query
#.Parameter query
#    Query string to use to query against the sqlConnection
#.Parameter args
#    An dictionary of objects to reassign in the query, in the
#.Example
#	$ret = Get-Query $sqlConnection "SELECT Column_Foo FROM DatabaseBOO.dbo.Table_BAR WHERE Column_Baz = @Query" -args @{Query="Bang"}
#   $ret | Format-Table
#   (table of results shown here)
##>
function Get-Query {
    [cmdletBinding()]
    param(
        [System.Data.SqlClient.SqlConnection]$sqlConnection,
        [string]$query,
        $params = @{}
    )

    $cmd = $sqlConnection.CreateCommand()
    $cmd.CommandText = $query

    # Add keys (if any) to the query
    foreach ($key in $params.Keys)
    {
        # if passed a SqlNull, convert to a "real" null:
        if (($null -ne $params[$key]) -and ($params[$key -eq [System.DBNull]::Value))
        {
            [void]$cmd.Parameters.AddWithValue("@$($key)", $null)
        }
        else
        {
            [void]$cmd.Parameters.AddWithValue("@$($key)", $params[$key])
        }
    }

    [System.Data.DataTable]$returnTable = New-Object System.Data.DataTable
    $reader = $cmd.ExecuteReader()
    $returnTable.Load($reader)

    $reader.Close()
    if ($reader.RecordsAffected -ne -1) {
        Write-Verbose "$($reader.RecordsAffected) rows affected."
    }

    return $returnTable
}
