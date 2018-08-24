ALTER FUNCTION [dbo].[CanSendToEmail] 
(
	@id int
)
RETURNS varchar(max)
AS
BEGIN
	
	DECLARE @email varchar(max)
	--uses an already existing certificate 
	SELECT @email = CONVERT(VARCHAR(MAX), DecryptByKeyAutocert(CERT_ID('cert_mailing'), NULL, r.Email)) 
	FROM Recipient r
	WHERE r.Id = @id
	AND r.Unsubscribe = 0
	AND r.IsValid = 1
	
	RETURN @email
	
END
GO


