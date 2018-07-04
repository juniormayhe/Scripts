
DECLARE @emails TABLE (
    RecipientName varchar(200), 
    Email varchar(70)
)

DECLARE @id int = 0
WHILE(1 = 1)
BEGIN
	SELECT @id = MIN(Id)
	FROM [INFOSMART2].Gerencial.dbo.ITAccount WHERE Id > @id
	IF @id IS NULL 
		BREAK
	
	DECLARE @recipientName varchar(200) = '',@email varchar(100) = ''
	--emails could be separated by comma, transform it to semicolon
	SELECT @recipientName=[name], @email = REPLACE(Email,',',';') 
  FROM [SERVER].Catalog.dbo.Emails 
	WHERE Id = @id
	
	INSERT INTO @emails 
		SELECT @recipientName, item FROM dbo.StringSplit(@email, ';') 

END

SELECT RecipientName, Email FROM @emails
