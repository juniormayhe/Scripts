--Start at master database
USE [master]
GO

-- Check if current master database has a database master key
SELECT * FROM sys.symmetric_keys where [name] = '##MS_DatabaseMasterKey##'

--if there is a database master key and it is not used drop it
DROP MASTER KEY

--create a new database master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '1password';

--backup database master key
OPEN MASTER KEY DECRYPTION BY PASSWORD = '1password';   
BACKUP SERVICE MASTER KEY TO FILE = 'C:\TEMP\service_master_key' ENCRYPTION BY PASSWORD = '3ncpassword';
BACKUP MASTER KEY TO FILE = 'C:\TEMP\master_database_master_key' ENCRYPTION BY PASSWORD = '3ncpassword';
CLOSE MASTER KEY 

--Now go to target database
use MAILING
go	  

--Check if you already have symmetric key and a certificate
SELECT * FROM sys.symmetric_keys where [name]='symkey_mailing'
SELECT * FROM sys.certificates where [name]='cert_mailing'

-- if you have any, drop them
DROP SYMMETRIC KEY your_symkey_name  
DROP CERTIFICATE your_cert_name

--create certificate and symmetric key
CREATE CERTIFICATE your_cert_name 
	WITH SUBJECT = N'My db certificate', 
	START_DATE = N'2018-01-01', 
	EXPIRY_DATE = N'2040-12-31';

CREATE SYMMETRIC KEY your_symkey_name WITH  
	KEY_SOURCE = 'My key generation bits. This is a shared secret!',  
	ALGORITHM = AES_256,   
	IDENTITY_VALUE = 'Key Identity generation bits. Also a shared secret'  
	ENCRYPTION BY CERTIFICATE your_cert_name;  

-- add the column that will hold encrypted data
ALTER TABLE Recipient 
ADD [EncryptedEmail] [VARBINARY](MAX) NULL

-- load the new column with eycrypted data using certificate and symmetric key created before
OPEN SYMMETRIC KEY symkey_mailing DECRYPTION BY CERTIFICATE your_cert_name;  
UPDATE Recipient SET EncryptedEmail = EncryptByKey(Key_GUID('your_symkey_name'), Email)
CLOSE SYMMETRIC KEY your_symkey_name

--drop the unprotected column
ALTER TABLE Recipient DROP COLUMN Email

--rename the new column you just added EncryptedEmail to a suitable name like Email 
exec sp_rename @objname = 'MAILING.dbo.Recipient.EncryptedEmail', @newname = 'Email', @objtype = 'COLUMN'

-- review if data is being decrypted
OPEN SYMMETRIC KEY your_symkey_name DECRYPTION BY CERTIFICATE your_cert_name;  
SELECT Email, CONVERT(varchar(max), DecryptByKey(Email)) AS 'DecryptedEmail' FROM Recipient;  
CLOSE SYMMETRIC KEY your_symkey_name;

