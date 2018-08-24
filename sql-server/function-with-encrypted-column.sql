ALTER FUNCTION [dbo].[CanSendToEmail] 
(
	@id int
)
RETURNS varchar(70)
AS
BEGIN
	
	DECLARE @email varchar(70)
	--uses an already existing certificate 
	SELECT @email = DecryptByKeyAutocert(CERT_ID('cert_mailing'), NULL, r.Email) as Email 
	FROM Recipient r
	AND r.Unsubscribe = 0
	AND r.IsValid = 1
	
	RETURN @email
	
END
GO


