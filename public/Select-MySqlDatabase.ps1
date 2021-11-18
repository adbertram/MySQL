function Select-MySqlDatabase
{
    <#
        .SYNOPSIS
            Set the default database to work with
        .DESCRIPTION
            This function sets the default database to use, this value is 
            pulled from the connection object on functions that have database 
            as a parameter.
        .PARAMETER Connection
        .PARAMETER Database
        .EXAMPLE
            # jspatton@IT08082 | 16:35:02 | 02-16-2015 | C:\projects\mod-posh\powershell\production $
            Connect-MySqlServer -Credential (Get-Credential)

            cmdlet Get-Credential at command pipeline position 1
            Supply values for the following parameters:
            Credential


            ServerThread      : 12
            DataSource        : localhost
            ConnectionTimeout : 15
            Database          :
            UseCompression    : False
            State             : Open
            ServerVersion     : 5.6.22-log
            ConnectionString  : server=localhost;port=3306;User Id=root
            IsPasswordExpired : False
            Site              :
            Container         :



            # jspatton@IT08082 | 16:35:13 | 02-16-2015 | C:\projects\mod-posh\powershell\production $
            Get-MySqlDatabase

            Database
            --------
            information_schema
            mynewdb
            mysql
            mytest
            performance_schema
            test
            testing
            wordpressdb
            wordpressdb1
            wordpressdb2


            # jspatton@IT08082 | 16:35:24 | 02-16-2015 | C:\projects\mod-posh\powershell\production $
            Select-MySqlDatabase -Database mytest


            ServerThread      : 12
            DataSource        : localhost
            ConnectionTimeout : 15
            Database          : mytest
            UseCompression    : False
            State             : Open
            ServerVersion     : 5.6.22-log
            ConnectionString  : server=localhost;port=3306;User Id=root
            IsPasswordExpired : False
            Site              :
            Container         :

            Description
            -----------
            This example shows connecting to MySQL Server, you can see there is no value for database. 
            Then we list all the databases on the server, and finally we select the mytest database. 
            The output of the command shows that we are now using mytest.
        .NOTES
            FunctionName : Select-MySqlDatabase
            Created by   : jspatton
            Date Coded   : 02/16/2015 16:29:43
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Select-MySqlDatabase
    #>	
	[OutputType('MySql.Data.MySqlClient.MySqlConnection')]
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Database,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[MySql.Data.MySqlClient.MySqlConnection]$Connection = $MySQLConnection
	)
	process
	{
		try
		{
			if (-not (Get-MySqlDatabase -Connection $Connection -Name $Database))
			{
				throw "Unknown database $($Database)"
			}
			else
			{
				$Connection.ChangeDatabase($Database)
			}
			$Global:MySQLConnection = $Connection
			$Connection
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}