ALTER FUNCTION [dbo].[StringSplit] (
	@delimitedString VARCHAR(8000),
	@separator VARCHAR(8000) = ','
)
RETURNS @list TABLE (item VARCHAR(8000))
BEGIN
        DECLARE @sItem VARCHAR(8000)
        WHILE CHARINDEX(@separator, @delimitedString, 0) <> 0
		BEGIN
			SELECT  @sItem = RTRIM(LTRIM(SUBSTRING(@delimitedString, 1, CHARINDEX(@separator, @delimitedString, 0) - 1))) ,
                        @delimitedString = RTRIM(LTRIM(SUBSTRING(@delimitedString, CHARINDEX(@separator, @delimitedString, 0) + LEN(@separator), LEN(@delimitedString))))
 
            IF LEN(@sItem) > 0
                INSERT INTO @list
                       SELECT @sItem
        END

        IF LEN(@delimitedString) > 0
            INSERT INTO @list
                       SELECT @delimitedString
        RETURN
END
