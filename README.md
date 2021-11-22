# MySQL-WithBlob 
#### PowerShell MySQL Module with BLOB and Stream support.

This is a fork of the MySQL Module originally created by Jeff Patton and Adam Bertram.   I first found the module when I was attempting to do some work in PowerShell that required accessing a MySQL database.    The Module worked fiarly well but there were some issues with the portion that added parameters to the Query.   While re-writing that I also found that I needed to add BLOB data in the form of Images into one of my Queries.   Finally I added the ability to accept a BLOB stream and push it to a MySQL BLOB data field.

I'll try to add some documentation on how to use the module and some sample code snippits as I go along.

The module has been broken into individual function files.   This makes the update and editor process easier.   They now dynamically load and export.   I created 2 directory structures one for private and public functions.

###TO-DO:
Fix a bug in the MySQL Parameter querty when only one item is referenced.

