--FIND DUPLICATE ROWS
WITH CTE AS(
   SELECT [IdRecipient], [RecipientName], [Unsubscribe], [IsValid], [Email],
       RN = ROW_NUMBER()OVER(PARTITION BY Email ORDER BY Email)
   FROM dbo.Recipient
)
SELECT * from CTE WHERE RN > 1

GO

--DELETE DUPLICATE ROWS
WITH CTE AS(
   SELECT [IdRecipient], [RecipientName], [Unsubscribe], [IsValid], [Email],
       RN = ROW_NUMBER()OVER(PARTITION BY Email ORDER BY Email)
   FROM dbo.Recipient
)
DELETE FROM CTE WHERE RN > 1
