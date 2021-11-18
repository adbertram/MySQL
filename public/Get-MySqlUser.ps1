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