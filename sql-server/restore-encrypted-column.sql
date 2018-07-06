-- check if the new server has a database master key and drop it if possible
use [master]
go
SELECT * FROM sys.symmetric_keys where [name] = '##MS_DatabaseMasterKey##'
DROP MASTER KEY

--create a new database master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '1password';

--restore they keys you have backuped from original server
RESTORE SERVICE MASTER KEY 
	FROM FILE = 'C:\Temp\service_master_key' 
	DECRYPTION BY PASSWORD = '3ncodedpass';  

RESTORE MASTER KEY   
    FROM FILE = 'C:\Temp\master_database_master_key'   
    DECRYPTION BY PASSWORD = '3ncodedpass'   
    ENCRYPTION BY PASSWORD = '1password';
    
-- check if database master key was createad
SELECT * FROM sys.symmetric_keys where [name] = '##MS_DatabaseMasterKey##'

-- restore the database to the new server. certificate and symmetric key must have been created before backup. then, check if those keys are present
use [Mailing]
go

SELECT * FROM sys.symmetric_keys where [name]='your_symkey_name'
SELECT * FROM sys.certificates where [name]='your_cert_name'

-- check if data can be decrypted using certificate and symmetric key backed within your database backuo file
OPEN SYMMETRIC KEY symkey_mailing DECRYPTION BY CERTIFICATE your_cert_name;  
SELECT Email, CONVERT(varchar(max), DecryptByKey(Email)) AS 'DecryptedEmail' FROM Recipient;  
CLOSE SYMMETRIC KEY your_symkey_name;
