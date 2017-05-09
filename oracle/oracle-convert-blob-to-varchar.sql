declare
  c clob;
  n number;
  
begin
    
    for data in (select * from R960PAR)
    loop
            
          if (data.parval is null) then 
            continue;
          end if;
  
          if (length(data.parval)=0) then
            continue; 
        end if;
        
        dbms_lob.createtemporary(c,true);
        n:=1;
        
        --while (n+32767<=length(data.parval)) loop
           --dbms_lob.writeappend(c,32767,utl_raw.cast_to_varchar2(dbms_lob.substr(data.parval,32767,n)));
            --n:=n+32767;
        --end loop;
        
        while (n<=2000) loop
           dbms_lob.writeappend(c,2000,utl_raw.cast_to_varchar2(dbms_lob.substr(data.parval,2000,n)));
            n:=2000;
        end loop;
        
        dbms_lob.writeappend(c,length(data.parval)-n+1,utl_raw.cast_to_varchar2(dbms_lob.substr(data.parval,length(data.parval)-n+1,n)));
        
        dbms_output.put_line(c);
    end loop;
end;