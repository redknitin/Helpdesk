function getHttpRequest() {
   httpRequest = null

   if (window.XMLHttpRequest) { // Mozilla, Safari, IE7+ ...
       httpRequest = new XMLHttpRequest();
   } else if (window.ActiveXObject) { // IE 6 and older
       httpRequest = new ActiveXObject("Microsoft.XMLHTTP");
   }

   return httpRequest;
}



function loadOrg() {} //Unused - this will always be statically populated



function loadRoom(floorDdl) {
 //This function will be called onChange from the floor ddl
 
// selectedValue = '<%= (@rec == nil || @rec[:locroom] == nil || @rec[:locroom] == '') ? '' : @rec[:locroom] %>';

 try {
   httpRequest = getHttpRequest();

   //httpRequest.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
   httpRequest.onreadystatechange = function(){
       // Process the server response here.
       if (httpRequest.readyState === XMLHttpRequest.DONE) {
           // Everything is good, the response was received.
           if (httpRequest.status === 200) {
               // Perfect!
               //httpRequest.responseText
               //httpRequest.responseXML

               deptddl = document.getElementById("locroom");
               deptddl.options.length = 0;
               ddlvals = JSON.parse(httpRequest.responseText);
               if (ddlvals != null) {
                   //deptddl = document.getElementById("dept"); //$('#dept')[0]; //$('#dept').get(0)

                   iteropt = document.createElement('option');
                   iteropt.innerHTML = iteropt.value = '';
                   deptddl.appendChild(iteropt);

                   for (i=0; i<ddlvals.length; i++) {
                       iteropt = document.createElement('option');
                       iteropt.innerHTML = ddlvals[i].label;
                       iteropt.value = ddlvals[i].value; //.text
//                       if (iteropt.value == selectedValue) iteropt.selected = true;
                       deptddl.appendChild(iteropt);
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

   httpRequest.open('GET', '/dropdown/locroom/'+document.getElementById('locorg').value+'/'+document.getElementById('locsite').value+'/'+document.getElementById('locbldg').value+'/'+floorDdl.value, true);
   httpRequest.send();
 }
 catch (e) { alert(e.description); }
}



function loadFloor(bldgDdl) {
 //This function will be called onChange from the bldg ddl
 
  document.getElementById("locroom").options.length = 0;
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
               //httpRequest.responseText
               //httpRequest.responseXML

               deptddl = document.getElementById("locfloor");
               deptddl.options.length = 0;
               ddlvals = JSON.parse(httpRequest.responseText);
               if (ddlvals != null) {
                   //deptddl = document.getElementById("dept"); //$('#dept')[0]; //$('#dept').get(0)

                   iteropt = document.createElement('option');
                   iteropt.innerHTML = iteropt.value = '';
                   deptddl.appendChild(iteropt);

                   for (i=0; i<ddlvals.length; i++) {
                       iteropt = document.createElement('option');
                       iteropt.innerHTML = ddlvals[i].label;
                       iteropt.value = ddlvals[i].value; //.text
//                       if (iteropt.value == selectedValue) iteropt.selected = true;
                       deptddl.appendChild(iteropt);
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

   httpRequest.open('GET', '/dropdown/locfloor/'+document.getElementById('locorg').value+'/'+document.getElementById('locsite').value+'/'+bldgDdl.value, true);
   httpRequest.send();
 }
 catch (e) { alert(e.description); }
}



function loadBldg(siteDdl) {
 //This function will be called onChange from the site ddl
 
  document.getElementById("locfloor").options.length = document.getElementById("locroom").options.length = 0;
// selectedValue = '<%= (@rec == nil || @rec[:locbldg] == nil || @rec[:locbldg] == '') ? '' : @rec[:locbldg] %>';

 try {
   httpRequest = getHttpRequest();

   //httpRequest.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
   httpRequest.onreadystatechange = function(){
       // Process the server response here.
       if (httpRequest.readyState === XMLHttpRequest.DONE) {
           // Everything is good, the response was received.
           if (httpRequest.status === 200) {
               // Perfect!
               //httpRequest.responseText
               //httpRequest.responseXML

               deptddl = document.getElementById("locbldg");
               deptddl.options.length = 0;
               ddlvals = JSON.parse(httpRequest.responseText);
               if (ddlvals != null) {
                   //deptddl = document.getElementById("dept"); //$('#dept')[0]; //$('#dept').get(0)

                   iteropt = document.createElement('option');
                   iteropt.innerHTML = iteropt.value = '';
                   deptddl.appendChild(iteropt);

                   for (i=0; i<ddlvals.length; i++) {
                       iteropt = document.createElement('option');
                       iteropt.innerHTML = ddlvals[i].label;
                       iteropt.value = ddlvals[i].value; //.text
//                       if (iteropt.value == selectedValue) iteropt.selected = true;
                       deptddl.appendChild(iteropt);
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

   httpRequest.open('GET', '/dropdown/locbldg/'+document.getElementById('locorg').value+'/'+siteDdl.value, true);
   httpRequest.send();
 }
 catch (e) { alert(e.description); }
}



function loadSite(orgDdl) {
 //This function will be called onChange from the org ddl

  document.getElementById("locbldg").options.length = document.getElementById("locfloor").options.length = document.getElementById("locroom").options.length = 0;
// selectedValue = '<%= (@rec == nil || @rec[:locsite] == nil || @rec[:locsite] == '') ? '' : @rec[:locsite] %>';

 try {
   httpRequest = getHttpRequest();

   //httpRequest.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
   httpRequest.onreadystatechange = function(){
       // Process the server response here.
       if (httpRequest.readyState === XMLHttpRequest.DONE) {
           // Everything is good, the response was received.
           if (httpRequest.status === 200) {
               // Perfect!
               //httpRequest.responseText
               //httpRequest.responseXML

               deptddl = document.getElementById("locsite");
               deptddl.options.length = 0;
               ddlvals = JSON.parse(httpRequest.responseText);
               if (ddlvals != null) {
                   //deptddl = document.getElementById("dept"); //$('#dept')[0]; //$('#dept').get(0)

                   iteropt = document.createElement('option');
                   iteropt.innerHTML = iteropt.value = '';
                   deptddl.appendChild(iteropt);

                   for (i=0; i<ddlvals.length; i++) {
                       iteropt = document.createElement('option');
                       iteropt.innerHTML = ddlvals[i].label;
                       iteropt.value = ddlvals[i].value; //.text
//                       if (iteropt.value == selectedValue) iteropt.selected = true;
                       deptddl.appendChild(iteropt);
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

   httpRequest.open('GET', '/dropdown/locsite/'+orgDdl.value, true);
   httpRequest.send();
 }
 catch (e) { alert(e.description); }
}
