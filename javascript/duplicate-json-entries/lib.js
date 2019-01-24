jQuery(".process").click( function() {
   
   var dirty = JSON.parse( jQuery(".dirty").val().trim() );
   
   removeDuplicates(dirty);
   
});

function removeDuplicates(json_all) {
    var arr = [],
				duplicates=[],
				clean = [];
        
    $.each(json_all, function (index, value) {
        if ($.inArray(value.SizeCode, arr) == -1) {
            arr.push(value.SizeCode);
            clean.push(value);
        }
        else {
        	duplicates.push(value);
        }
    });
    jQuery(".clean").val( JSON.stringify(clean, null, "  ") );
    jQuery(".duplicates").val( JSON.stringify(duplicates, null, "  ") );
    
    jQuery("#totalduplicates").text(duplicates.length);
    
    return clean;
}
