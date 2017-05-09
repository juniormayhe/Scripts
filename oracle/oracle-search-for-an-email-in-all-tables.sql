
--search for an email in all tables 
declare
lcount number;
lquery varchar2(200);

begin
    dbms_output.enable;
    dbms_output.put_line('Starting...');

    for data in (select * from user_tab_columns)
    loop
		if data.data_type <> 'BLOB' then 
			--possible datatypes:
			--NUMBER
			--CLOB
			--CHAR
			--DATE
			--RAW
			--VARCHAR2
            lquery:= 'select count(*) from ' || data.table_name || ' where ' || data.column_name || ' like ''%@domain.com%''';
            execute immediate lquery into lcount;
            if lcount >0 then
                dbms_output.put_line('>> Column: select ' || data.column_name || ' from ' || data.table_name);
            end if;
        else
			--if datatype is BLOB we convert a blob column_name to clob / character large object
            lquery:= 'select count(*) from ' || data.table_name || ' where to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(' || data.column_name || ', 2000,1)))   like ''%@domain.com%''';
            execute immediate lquery into lcount;
            if lcount >0 then
                dbms_output.put_line('>> Column BLOB: select ' || data.column_name || ' from ' || data.table_name);
            end if;
            
        end if;
    end loop;
    dbms_output.put_line('Finished.');
	--select owner,table_name from all_tab_columns where upper(column_name) like upper('%keyword%');
end;
