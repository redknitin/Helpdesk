function getHttpRequest() {
   httpRequest = null

   if (window.XMLHttpRequest) { // Mozilla, Safari, IE7+ ...
       httpRequest = new XMLHttpRequest();
   } else if (window.ActiveXObject) { // IE 6 and older
       httpRequest = new ActiveXObject("Microsoft.XMLHTTP");
   }

   return httpRequest;
}
