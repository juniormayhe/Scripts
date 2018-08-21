--on target database where linked server was created, run:

USE [master]
GO
EXEC master.dbo.sp_serveroption @server=N'192.168.x.x', @optname=N'rpc out', @optvalue=N'true'
GO
