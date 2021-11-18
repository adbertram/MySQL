function Disconnect-MySqlServer
{
    <#
        .SYNOPSIS
            Disconnect a MySQL connection
        .DESCRIPTION
            This function will disconnect (logoff) a MySQL server connection
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .EXAMPLE
            $Connection = Connect-MySqlServer -Credential (Get-Credential)
            Disconnect-MySqlServer -Connection $Connection


            ServerThread      :
            DataSource        : localhost
            ConnectionTimeout : 15
            Database          :
            UseCompression    : False
            State             : Closed
            ServerVersion     :
            ConnectionString  : server=localhost;port=3306;User Id=root
            IsPasswordExpired :
            Site              :
            Container         :

            Description
            -----------
            This example shows connecting to the local instance of MySQL 
            Server and then disconnecting from it.
        .NOTES
            FunctionName : Disconnect-MySqlServer
            Created by   : jspatton
            Date Coded   : 02/11/2015 12:16:24
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Disconnect-MySqlServer
    #>	
	[OutputType('MySql.Data.MySqlClient.MySqlConnection')]
	[CmdletBinding()]
	Param
	(
		[Parameter(ValueFromPipeline)]
		[ValidateNotNullOrEmpty()]
		[MySql.Data.MySqlClient.MySqlConnection]$Connection = $MySQLConnection
	)
	process
	{
		try {
			$Connection.Close()
			$Connection
		}
		catch 
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}