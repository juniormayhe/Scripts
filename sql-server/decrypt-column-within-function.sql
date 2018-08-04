-- decrypt
DecryptByKeyAutocert(CERT_ID('your_cert_name'), NULL, a_column) = @a_variable 

-- or you could try to open and close symmetric keys
OPEN SYMMETRIC KEY your_symkey_name DECRYPTION BY CERTIFICATE your_cert_name;  

SELECT DecryptByKey(a_column)) as DecryptedColumn FROM YourTable;  

CLOSE SYMMETRIC KEY your_symkey_name;

--on ssms you can decrypt by key or autocert
SELECT  Email as encryptedEmail,
CONVERT(varchar(max), DecryptByKey(Email)) as convertDecryptByKey,
CONVERT(varchar(max), DecryptByKeyAutocert(CERT_ID('cert_mailing'), NULL, Email)) as convertDecryptByCert FROM Recipient;
