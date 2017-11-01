function ddlpopulate(ddl, arr) {
    ddl.options.length = 0;

    iteropt = document.createElement('option');
    iteropt.innerHTML = iteropt.value = '';
    ddl.appendChild(iteropt);

    for (i=0; i<arr.length; i++) {
        iteropt = document.createElement('option');
        iteropt.innerHTML = iteropt.value = arr[i]; //.text
        ddl.appendChild(iteropt);
    }
}

function ddlcascade(upper, lower, ht) {
	objUpper = document.getElementById(upper);
	objLower = document.getElementById(lower);
	if (objUpper.options.length == 0) {
		ddlpopulate(objUpper, Object.keys(ht));
	}
	objUpper.onchange = function() {
		ddlpopulate(objLower, ht[objUpper.value]);
	}
}

/*
//If using jQuery, use $(document).ready, or find and call other onload handlers
window.onload = function() {
	hyper01 = { 'nose' : ['N-X', 'N-L', 'N-M', 'N-S'], 'lips' : ['L-STD'], 'ear': ['E-L', 'E-S'] };
	ddlcascade('ddl01', 'ddl02', hyper01);
}
*/
