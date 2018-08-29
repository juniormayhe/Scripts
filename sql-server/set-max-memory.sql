
/*
Assumptions
You're only running one SQL Server
You're not running SSIS, SSRS, SSAS, etc.
You're not using it to run any other applications on the server
*/

-- recommended settings
--GB	MB	    Recommended Setting	
--16	16384	  12288	
EXEC sys.sp_configure 'max server memory (MB)', '12288'; RECONFIGURE;

--32	32768	29491	
EXEC sys.sp_configure 'max server memory (MB)', '29491'; RECONFIGURE;

--64	65536	58982	
EXEC sys.sp_configure 'max server memory (MB)', '58982'; RECONFIGURE;

--128	131072	117964	
EXEC sys.sp_configure 'max server memory (MB)', '117964'; RECONFIGURE;

--256	262144	235929	
EXEC sys.sp_configure 'max server memory (MB)', '235929'; RECONFIGURE;

--512	524288	471859	
EXEC sys.sp_configure 'max server memory (MB)', '471859'; RECONFIGURE;

--1024	1048576	943718	
EXEC sys.sp_configure 'max server memory (MB)', '943718'; RECONFIGURE;

--2048	2097152	1887436	
EXEC sys.sp_configure 'max server memory (MB)', '1887436'; RECONFIGURE;

--4096	4194304	3774873	
EXEC sys.sp_configure 'max server memory (MB)', '3774873'; RECONFIGURE;
