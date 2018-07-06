-- decrypt
DecryptByKeyAutocert(CERT_ID('your_cert_name'), NULL, a_column) = @a_variable 

-- or you could try to open and close symmetric keys
OPEN SYMMETRIC KEY your_symkey_name DECRYPTION BY CERTIFICATE your_cert_name;  

SELECT DecryptByKey(a_column)) as DecryptedColumn FROM YourTable;  

CLOSE SYMMETRIC KEY your_symkey_name;
