function Get-MySqlTable
{
    <#
        .SYNOPSIS
            Get a list of one or more tables on a database
        .DESCRIPTION
            This function will return one or more tables on a database.
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER Database
            The name of the database to get tables from
        .PARAMETER Table
            The name of the table to get
        .EXAMPLE
            Get-MySqlTable -Connection $Connection

            Tables_in_test
            --------------
            bar

            Description
            -----------
            A listing of tables from the database the connection is already attached to
        .EXAMPLE
            Get-MySqlTable -Connection $Connection -Database wordpressdb

            Tables_in_wordpressdb
            ---------------------
            foo
            bar
            sample_tbl

            Description
            -----------
            A listing of tables from the wordpressdb database
        .EXAMPLE
            Get-MySqlTable -Connection $Connection -Database wordpressdb -Table sample_tbl

            Tables_in_wordpressdb
            ---------------------
            sample_tbl

            Description
            -----------
            The sample_tbl from the wordpressdb
        .NOTES
            FunctionName : Get-MySqlTable
            Created by   : jspatton
            Date Coded   : 02/11/2015 12:47:03
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Get-MySqlTable
    #>
	[CmdletBinding()]
	Param
	(
		[MySql.Data.MySqlClient.MySqlConnection]
		$Connection = $Global:MySQLConnection,
		
		[string]$Database,
		
		[string]$Table
	)
	begin
	{
		try
		{
			$ErrorActionPreference = "Stop";
			if ($Database)
			{
				if (Get-MySqlDatabase -Connection $Connection -Name $Database)
				{
					$Connection.ChangeDatabase($Database);
				}
				else
				{
					throw "Unknown database $($Database)";
				}
			}
			else
			{
				if (!($Connection.Database))
				{
					throw "Please connect to a specific database";
				}
			}
		}
		catch
		{
			$Error[0];
			break
		}
		$db = $Connection.Database;
		if ($Table)
		{
			$Query = "SHOW TABLES FROM $($db) WHERE ``Tables_in_$($db)`` LIKE '$($Table)';"
		}
		else
		{
			$Query = "SHOW TABLES FROM $($db);"
		}
	}
	Process
	{
		try
		{
			Write-Verbose "Invoking SQL";
			Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
		}
		catch
		{
			$Error[0];
			break
		}
	}
	End
	{
	}
}