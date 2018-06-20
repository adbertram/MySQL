Set-StrictMode -Version Latest

$null = [System.Reflection.Assembly]::LoadWithPartialName('MySql.Data')

function Connect-MySqlServer {
    <#
	.SYNOPSIS
		Connect to a MySQL Server
	.DESCRIPTION
		This function will establish a connection to a local or remote instance of 
		a MySQL Server. By default it will connect to the local instance on the 
		default port.
	.PARAMETER ComputerName
		The name of the remote computer to connect to, otherwise default to localhost
	.PARAMETER Port
		By default this is 3306, otherwise specify the correct value
	.PARAMETER Credential
		Typically this may be your root credentials, or to work in a specific 
		database the credentials with appropriate rights to do work in that database.
	.PARAMETER Database
		An optional parameter that will connect you to a specific database
	.PARAMETER CommandTimeOut
		By default command timeout is set to 30, otherwise specify the correct value
	.PARAMETER ConnectionTimeOut
		By default connection timeout is set to 15, otherwise specify the correct value
	.EXAMPLE
		Connect-MySqlServer -Credential (Get-Credential)

		cmdlet Get-Credential at command pipeline position 1
		Supply values for the following parameters:
		Credential


		ServerThread      : 2
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

		Description
		-----------
		Connect to the local mysql instance as root. This example uses the 
		Get-Credential cmdlet to prompt for username and password.
	.EXAMPLE
		Connect-MySqlServer -ComputerName db.company.com -Credential (Get-Credential)

		cmdlet Get-Credential at command pipeline position 1
		Supply values for the following parameters:
		Credential


		ServerThread      : 2
		DataSource        : db.company.com
		ConnectionTimeout : 15
		Database          :
		UseCompression    : False
		State             : Open
		ServerVersion     : 5.6.22-log
		ConnectionString  : server=db.company.com;port=3306;User Id=root
		IsPasswordExpired : False
		Site              :
		Container         :

		Description
		-----------
		Connect to a remote mysql instance as root. This example uses the 
		Get-Credential cmdlet to prompt for username and password.
	.EXAMPLE
		Connect-MySqlServer -Credential (Get-Credential) -CommandTimeOut 60 -ConnectionTimeOut 25

		cmdlet Get-Credential at command pipeline position 1
		Supply values for the following parameters:
		Credential


		ServerThread      : 2
		DataSource        : localhost
		ConnectionTimeout : 25
		Database          :
		UseCompression    : False
		State             : Open
		ServerVersion     : 5.6.22-log
		ConnectionString  : server=localhost;port=3306;User Id=root;defaultcommandtimeout=60;connectiontimeout=25
		IsPasswordExpired : False
		Site              :
		Container         :

		Description
		-----------
		This example set the Command Timout to 60 and the Connection Timeout to 25. Both are optional when calling the Connect-MySqlServer function.
	.NOTES
		FunctionName : Connect-MySqlServer
		Created by   : jspatton
		Date Coded   : 02/11/2015 09:19:10
	.LINK
		https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Connect-MySqlServer
	#>
    [OutputType('MySql.Data.MySqlClient.MySqlConnection')]
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential,
		
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName = $env:COMPUTERNAME,
		
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$Port = 3306,
		
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Database,
		
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$CommandTimeOut = 30,
		
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$ConnectionTimeOut = 15,
		
        [Parameter()]
        [switch]
        $UseSSL
    )
    begin {	
        $ErrorActionPreference = 'Stop'
		
        if ($PSBoundParameters.ContainsKey('Database')) {
            $connectionString = 'server={0};port={1};uid={2};pwd={3};database={4};' -f $ComputerName, $Port, $Credential.UserName, $Credential.GetNetworkCredential().Password, $Database
        }
        else {
            $connectionString = 'server={0};port={1};uid={2};pwd={3};' -f $ComputerName, $Port, $Credential.UserName, $Credential.GetNetworkCredential().Password
        }
        # Added
        If (($UseSSL)) {
            
            $connectionString = $connectionString + "default command timeout=$CommandTimeOut; Connection Timeout=$ConnectionTimeOut;Allow User Variables=True"

        }

        Else {

            $connectionString = $connectionString + "default command timeout=$CommandTimeOut; Connection Timeout=$ConnectionTimeOut;Allow User Variables=True;SslMode=None"

        }    
	}
    process {
        try {
            [MySql.Data.MySqlClient.MySqlConnection]$conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
            $conn.Open()
            $Global:MySQLConnection = $conn
            if ($PSBoundParameters.ContainsKey('Database')) {
                $null = New-Object MySql.Data.MySqlClient.MySqlCommand("USE $Database", $conn)
            }
            $conn
        }
        catch {
            Write-Error -Message $_.Exception.Message
        }
    }
}

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

function New-MySqlDatabase
{
    <#
        .SYNOPSIS
            Create a new MySQL DB
        .DESCRIPTION
            This function will create a new Database on the server that you are 
            connected to.
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER Name
            The name of the database to create
        .EXAMPLE
            New-MySqlDatabase -Connection $Connection -Name "MyNewDB"

            Database
            --------
            mynewdb

            Description
            -----------
            This example creates the MyNewDB database on a MySQL server.
        .NOTES
            FunctionName : New-MySqlDatabase
            Created by   : jspatton
            Date Coded   : 02/11/2015 09:35:02
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#New-MySqlDatabase
    #>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[MySql.Data.MySqlClient.MySqlConnection]$Connection = $MySQLConnection
	)
	begin
	{
		$Query = "CREATE DATABASE $($Name);";
	}
	process
	{
		try
		{
			Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop
			Get-MySqlDatabase -Connection $Connection -Name $Name
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}

function Get-MySqlDatabase
{
    <#
        .SYNOPSIS
            Get one or more tables from a MySQL Server
        .DESCRIPTION
            This function returns one or more Database names from a MySQL Server
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER Name
            An optional parameter that if provided will scope the output to the requested 
            DB. If blank this will return all the Datbases the user has the ability to 
            see based on their credentials.
        .EXAMPLE
            Get-MySqlDatabase -Connection $Connection

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
            This example shows the output when the Name parameter is ommitted.
        .EXAMPLE
            Get-MySqlDatabase -Connection $Connection -Name mynewdb

            Database
            --------
            mynewdb

            Description
            -----------
            This example shows the output when passing in the name of a Database.
        .NOTES
            FunctionName : Get-MySqlDatabase
            Created by   : jspatton
            Date Coded   : 02/11/2015 10:05:20
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Get-MySqlDatabase
    #>
	[CmdletBinding()]
	Param
	(
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[MySql.Data.MySqlClient.MySqlConnection]$Connection = $MySQLConnection,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Name
	)
	process
	{
		try
		{
			if ($PSBoundParameters.ContainsKey('Name'))
			{
				$query = "SHOW DATABASES WHERE ``Database`` LIKE '$($Name)';"
			}
			else
			{
				$query = 'SHOW DATABASES;'
			}
			Invoke-MySqlQuery -Connection $Connection -Query $query -ErrorAction Stop
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}

function New-MySqlUser
{
    <#
        .SYNOPSIS
            Create a MySQL User
        .DESCRIPTION
            This function will create a user in the MySQL Server.
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER Credential
            A Credential object that represents the user and password to be created on MySQL
        .EXAMPLE
            New-MySqlUser -Connection $Connection -Credential (Get-Credential)

            cmdlet Get-Credential at command pipeline position 1
            Supply values for the following parameters:
            Credential


            Host                   : localhost
            User                   : user-01
            Password               : *2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19
            Select_priv            : N
            Insert_priv            : N
            Update_priv            : N
            Delete_priv            : N
            Create_priv            : N
            Drop_priv              : N
            Reload_priv            : N
            Shutdown_priv          : N
            Process_priv           : N
            File_priv              : N
            Grant_priv             : N
            References_priv        : N
            Index_priv             : N
            Alter_priv             : N
            Show_db_priv           : N
            Super_priv             : N
            Create_tmp_table_priv  : N
            Lock_tables_priv       : N
            Execute_priv           : N
            Repl_slave_priv        : N
            Repl_client_priv       : N
            Create_view_priv       : N
            Show_view_priv         : N
            Create_routine_priv    : N
            Alter_routine_priv     : N
            Create_user_priv       : N
            Event_priv             : N
            Trigger_priv           : N
            Create_tablespace_priv : N
            ssl_type               :
            ssl_cipher             : {}
            x509_issuer            : {}
            x509_subject           : {}
            max_questions          : 0
            max_updates            : 0
            max_connections        : 0
            max_user_connections   : 0
            plugin                 : mysql_native_password
            authentication_string  :
            password_expired       : N

            Description
            -----------
            This example uses the Get-Credential object to create a user (user-01) on the MySQL Server
        .NOTES
            FunctionName : New-MySqlUser
            Created by   : jspatton
            Date Coded   : 02/11/2015 10:28:35
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#New-MySqlUser
    #>
	[CmdletBinding()]
	Param
	(
		[MySql.Data.MySqlClient.MySqlConnection]
		$Connection = $Global:MySQLConnection,
		
		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]$Credential
	)
	begin
	{
		$Query = "CREATE USER '$($Credential.UserName)'@'$($Connection.DataSource)' IDENTIFIED BY '$($Credential.GetNetworkCredential().Password)';";
	}
	Process
	{
		try
		{
			Write-Verbose "Invoking SQL";
			Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
			Write-Verbose "Getting newly created user";
			Get-MySqlUser -Connection $Connection -User $Credential.UserName;
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

function Get-MySqlUser
{
    <#
        .SYNOPSIS
            Get one or more MySQL Server users
        .DESCRIPTION
            This function will return a list of users from the MySQL server when you omit the User parameter.
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER User
            An optional parameter that represents the username of a MySQL Server user
        .EXAMPLE
            Get-MySqlUser -Connection $Connection |Format-Table

            Host        User        Password    Select_priv Insert_priv Update_priv Delete_priv Create_priv Drop_priv   Reload_priv
            ----        ----        --------    ----------- ----------- ----------- ----------- ----------- ---------   -----------
            localhost   root        *A158E86... Y           Y           Y           Y           Y           Y           Y
            127.0.0.1   root        *A158E86... Y           Y           Y           Y           Y           Y           Y
            ::1         root        *A158E86... Y           Y           Y           Y           Y           Y           Y
            localhost   user-01     *2470C0C... N           N           N           N           N           N           N

            Description
            -----------
            This example shows the output when omitting the optional parameter user
        .EXAMPLE
            Get-MySqlUser -Connection $Connection -User user-01


            Host                   : localhost
            User                   : user-01
            Password               : *2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19
            Select_priv            : N
            Insert_priv            : N
            Update_priv            : N
            Delete_priv            : N
            Create_priv            : N
            Drop_priv              : N
            Reload_priv            : N
            Shutdown_priv          : N
            Process_priv           : N
            File_priv              : N
            Grant_priv             : N
            References_priv        : N
            Index_priv             : N
            Alter_priv             : N
            Show_db_priv           : N
            Super_priv             : N
            Create_tmp_table_priv  : N
            Lock_tables_priv       : N
            Execute_priv           : N
            Repl_slave_priv        : N
            Repl_client_priv       : N
            Create_view_priv       : N
            Show_view_priv         : N
            Create_routine_priv    : N
            Alter_routine_priv     : N
            Create_user_priv       : N
            Event_priv             : N
            Trigger_priv           : N
            Create_tablespace_priv : N
            ssl_type               :
            ssl_cipher             : {}
            x509_issuer            : {}
            x509_subject           : {}
            max_questions          : 0
            max_updates            : 0
            max_connections        : 0
            max_user_connections   : 0
            plugin                 : mysql_native_password
            authentication_string  :
            password_expired       : N

            Description
            -----------
            This shows the output when passing in a value for User
        .NOTES
            FunctionName : Get-MySqlUser
            Created by   : jspatton
            Date Coded   : 02/11/2015 10:45:50
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Get-MySqlUser
    #>
	[CmdletBinding()]
	Param
	(
		[MySql.Data.MySqlClient.MySqlConnection]
		$Connection = $Global:MySQLConnection,
		
		[string]$User
	)
	begin
	{
		if ($User)
		{
			$Query = "SELECT * FROM mysql.user WHERE ``User`` LIKE '$($User)';";
		}
		else
		{
			$Query = "SELECT * FROM mysql.user;"
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

function New-MySqlTable
{
    <#
        .SYNOPSIS
            Create a table 
        .DESCRIPTION
            This function creates a table
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER Table
            The name of the table to create
        .PARAMETER Database
            The name of the database to create the table in, if blank the current database
        .PARAMETER Column
            A hashtable containing at least a name and datatype for a row to be 
            created in the table. For example it could be something as simple or 
            complex as the following
                @{"id"="INT"}
                @{"id"="INT(11) NOT NULL AUTO_INCREMENT","PRIMARY KEY"="(id)"} 
        .EXAMPLE
            $Fields.GetEnumerator()

            Name                           Value
            ----                           -----
            Death                          DATE
            Birth                          DATE
            Owner                          VARCHAR (20)
            Species                        VARCHAR (20)
            Sex                            VARCHAR (1)
            Name                           VARCHAR (20)

            New-MySqlTable -Connection $Connection -Table bar -Column $Fields

            Tables_in_wordpressdb
            ---------------------
            bar

            Description
            -----------
            This example shows using a hashtable object to set the field names 
            and values of the various fields to be created in the new table. It 
            then shows how to create a table with that object.
        .EXAMPLE
            New-MySqlTable -Connection $Connection -Table sample_tbl -Column @{"id"="INT(11) NOT NULL AUTO_INCREMENT";"PRIMARY KEY"="(id)"}


            Tables_in_wordpressdb
            ---------------------
            sample_tbl

            Description
            -----------
            This example shows creating a table and passing in the column defintions on the command line
        .NOTES
            FunctionName : New-MySqlTable
            Created by   : jspatton
            Date Coded   : 02/11/2015 12:31:18
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#New-MySqlTable
    #>
	[CmdletBinding()]
	Param
	(
		[MySql.Data.MySqlClient.MySqlConnection]
		$Connection = $Global:MySQLConnection,
		
		[parameter(Mandatory = $true)]
		[string]$Table,
		
		[string]$Database,
		
		[parameter(Mandatory = $true)]
		[hashtable]$Column
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
		$Fields = "";
		foreach ($C in $Column.GetEnumerator()) { $Fields += "$($C.Name) $($C.Value)," };
		$Fields = $Fields.Substring(0, $Fields.Length - 1);
		Write-Verbose $Fields;
		$Query = "CREATE TABLE $($Table) ($($Fields));"
	}
	Process
	{
		try
		{
			Write-Verbose "Invoking SQL";
			Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
			Write-Verbose "Getting newly created table";
			Get-MySqlTable -Connection $Connection -Table $Table;
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

function Get-MySqlColumn
{
    <#
        .SYNOPSIS
            Get a list of columns in a table
        .DESCRIPTION
            This function will return a list of columns from a table. 
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER Database
            The name of the database that contains the table
        .PARAMETER Table
            The name of the table to return columns from
        .EXAMPLE
            Get-MySqlColumn -Connection $Connection -Table sample_tbl


            Field   : id
            Type    : int(11)
            Null    : NO
            Key     : PRI
            Default :
            Extra   : auto_increment

            Field   : name
            Type    : varchar(10)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : age
            Type    : int(11)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Description
            -----------
            A list of fields from the sample_tbl in the current database
        .EXAMPLE
            Get-MySqlColumn -Connection $Connection -Database test -Table bar


            Field   : NAME
            Type    : varchar(20)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : OWNER
            Type    : varchar(20)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : DEATH
            Type    : date
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : BIRTH
            Type    : date
            Null    : YES
            Key     :
            Default :
            Extra   :

            Description
            -----------
            A list of fields from the bar table in the test database
        .NOTES
            FunctionName : Get-MySqlField
            Created by   : jspatton
            Date Coded   : 02/11/2015 13:17:25
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Get-MySqlField
    #>
	[CmdletBinding()]
	Param
	(
		[MySql.Data.MySqlClient.MySqlConnection]
		$Connection = $Global:MySQLConnection,
		
		[string]$Database,
		
		[parameter(Mandatory = $true)]
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
		$Query = "DESC $($Table);";
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

function Add-MySqlColumn
{
    <#
        .SYNOPSIS
            Add a column to a MySQL table
        .DESCRIPTION
            This function will add one or more columns to a MySQL table
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER Database
            The name of the database to connect ot
        .PARAMETER Table
            The name of the table to add a column to
        .PARAMETER Column
            A hashtable containing at least a name and datatype for a row to be 
            created in the table. For example it could be something as simple or 
            complex as the following
                @{"id"="INT"}
                @{"id"="INT(11) NOT NULL AUTO_INCREMENT";"PRIMARY KEY"="(id)";"Species"="VARCHAR(20)"} 
        .EXAMPLE
            Add-MySqlColumn -Connection $Connection -Database test -Table bar -Column @{"id"="INT(11) NOT NULL AUTO_INCREMENT";"PRIMARY KEY"="(id)";"Species"="VARCHAR(20)"}

            Field   : NAME
            Type    : varchar(20)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : OWNER
            Type    : varchar(20)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : DEATH
            Type    : date
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : BIRTH
            Type    : date
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : id
            Type    : int(11)
            Null    : NO
            Key     : PRI
            Default :
            Extra   : auto_increment

            Field   : Species
            Type    : varchar(20)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Description
            -----------
            This example shows how to add multiple columns to a table
        .NOTES
            FunctionName : Add-MySqlColumn
            Created by   : jspatton
            Date Coded   : 02/11/2015 13:21:29
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Add-MySqlColumn
    #>
	[CmdletBinding()]
	Param
	(
		[MySql.Data.MySqlClient.MySqlConnection]
		$Connection = $Global:MySQLConnection,
		
		[string]$Database,
		
		[parameter(Mandatory = $true)]
		[string]$Table,
		
		[parameter(Mandatory = $true)]
		[hashtable]$Column
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
			$Fields = "";
			foreach ($C in $Column.GetEnumerator()) { $Fields += "$($C.Name) $($C.Value)," };
			$Fields = $Fields.Substring(0, $Fields.Length - 1);
			Write-Verbose $Fields;
			$Query = "ALTER TABLE $($Table) ADD ($($Fields));";
		}
		catch
		{
			$Error[0];
			break
		}
	}
	Process
	{
		try
		{
			Write-Verbose "Invoking SQL";
			Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
			Get-MySqlColumn -Connection $Connection -Database $Database -Table $Table;
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
