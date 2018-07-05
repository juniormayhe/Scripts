--fill id column on existing table, idColumn here was added and is null
DECLARE @maxId int = 0

UPDATE ExistingTable
  SET  @maxId = idColumn = @maxId +1
WHERE idColumn IS NULL
