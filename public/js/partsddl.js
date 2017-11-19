function partselchg(cbo) {
 //This function will be called onChange from the part ddl
 
 uomddl = document.getElementById("uomddl");
 uomddl.options.length = 0;
// selectedValue = '<%= (@rec == nil || @rec[:locfloor] == nil || @rec[:locfloor] == '') ? '' : @rec[:locfloor] %>';

 try {
   httpRequest = getHttpRequest();

   //httpRequest.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
   httpRequest.onreadystatechange = function(){
       // Process the server response here.
       if (httpRequest.readyState === XMLHttpRequest.DONE) {
           // Everything is good, the response was received.
           if (httpRequest.status === 200) {
               // Perfect!
               ddlvals = JSON.parse(httpRequest.responseText);
               if (ddlvals != null) {
                   iteropt = document.createElement('option');
                   iteropt.innerHTML = iteropt.value = '';
                   uomddl.appendChild(iteropt);

                   isFirst = true;

                   for (i=0; i<ddlvals.length; i++) {
                       iteropt = document.createElement('option');
                       iteropt.innerHTML = ddlvals[i].label;
                       iteropt.value = ddlvals[i].value; //.text

                       if (isFirst) {
                        iteropt.selected = true;
                        isFirst = false;
                       }

//                       if (iteropt.value == selectedValue) iteropt.selected = true;
                       uomddl.appendChild(iteropt);
                   }
               }

           } else {
               // There was a problem with the request.
               // For example, the response may have a 404 (Not Found)
               // or 500 (Internal Server Error) response code.
           }
       } else {
           // Not ready yet.
       }
   };

   httpRequest.open('GET', '/dropdown/partuom/'+cbo.value, true);
   httpRequest.send();
 }
 catch (e) { alert(e.description); }
}
