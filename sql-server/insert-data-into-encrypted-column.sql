OPEN SYMMETRIC KEY symkey_mailing DECRYPTION BY CERTIFICATE cert_mailing;

INSERT INTO Recipient (RecipientName,Unsubscribe,IsValid,Email)
     VALUES ('Full name', 0, 0, EncryptByKey(Key_GUID('symkey_mailing'), 'email@domain.com'));

CLOSE SYMMETRIC KEY symkey_mailing;
