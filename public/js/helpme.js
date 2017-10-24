//Cascading dropdowns for Organization and Department
function cascDdl() {
    deptddl = document.getElementById("dept");
    deptddl.options.length = 0;
    ddlvals = cascadingData[document.getElementById("org").value]; //cascadingData[this.value]; //$('#org').val() //$(this).val()
    if (ddlvals != null) {
        //deptddl = document.getElementById("dept"); //$('#dept')[0]; //$('#dept').get(0)

        iteropt = document.createElement('option');
        iteropt.innerHTML = iteropt.value = '';
        deptddl.appendChild(iteropt);

        for (i=0; i<ddlvals.length; i++) {
            iteropt = document.createElement('option');
            iteropt.innerHTML = iteropt.value = ddlvals[i]; //.text
            deptddl.appendChild(iteropt);
        }
    }
}


//Cascading dropdowns for Building and Floor
function cascFloorDdl() {
    floorddl = document.getElementById("floor");
    floorddl.options.length = 0;
    ddlvals = cascadingFloors[document.getElementById("building").value]; //cascadingData[this.value]; //$('#org').val() //$(this).val()
    if (ddlvals != null) {
        //deptddl = document.getElementById("dept"); //$('#dept')[0]; //$('#dept').get(0)

        iteropt = document.createElement('option');
        iteropt.innerHTML = iteropt.value = '';
        floorddl.appendChild(iteropt);

        for (i=0; i<ddlvals.length; i++) {
            iteropt = document.createElement('option');
            iteropt.innerHTML = iteropt.value = ddlvals[i]; //.text
            floorddl.appendChild(iteropt);
        }
    }
}
