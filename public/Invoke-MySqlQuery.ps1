function Invoke-MySqlQuery
{
    <#
        .SYNOPSIS
            Run an ad-hoc query against a MySQL Server
        .DESCRIPTION
            This function can be used to run ad-hoc queries against a MySQL Server. 
            It is also used by nearly every function in this library to perform the 
            various tasks that are needed.
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER Query
            A valid MySQL query
        .EXAMPLE
            Invoke-MySqlQuery -Connection $Connection -Query "CREATE DATABASE sample_tbl;"

            Description
            -----------
            Create a table
        .EXAMPLE
            Invoke-MySqlQuery -Connection $Connection -Query "SHOW DATABASES;"

            Database
            --------
            information_schema
            mynewdb
            mysql
            performance_schema
            test
            testing
            wordpressdb
            wordpressdb1
            wordpressdb2

            Description
            -----------
            Return a list of databases
        .EXAMPLE
            Invoke-MySqlQuery -Connection $Connection -Query "INSERT INTO foo (Name) VALUES ('Bird'),('Cat');"

            Description
            -----------
            Add data to a sql table
        .NOTES
            FunctionName : Invoke-MySqlQuery
            Created by   : jspatton
            Date Coded   : 02/11/2015 11:09:26
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Invoke-MySqlQuery
    #>
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Query,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[MySql.Data.MySqlClient.MySqlConnection]$Connection = $MySQLConnection
	)
	begin
	{
		$ErrorActionPreference = 'Stop'
	}
	Process
	{
		try
		{
			
			[MySql.Data.MySqlClient.MySqlCommand]$command = New-Object MySql.Data.MySqlClient.MySqlCommand
			$command.Connection = $Connection
			$command.CommandText = $Query
			[MySql.Data.MySqlClient.MySqlDataAdapter]$dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($command)
			$dataSet = New-Object System.Data.DataSet
			$recordCount = $dataAdapter.Fill($dataSet)
			Write-Verbose "$($recordCount) records found"
			$dataSet.Tables.foreach{$_}
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}