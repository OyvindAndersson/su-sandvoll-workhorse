/** Init on body load */
function init() {
    sketchup.onload();

    // Intercept the main form on submit
    var moduleForm = document.getElementById('module-form');
    moduleForm.onsubmit = send_formdata;

    var tplSelectBox = document.getElementById('templates_selectbox');
    tplSelectBox.onchange = (e) => {
        console.log(e.target.value);
        /*
        let select = e.target;
        if(select.selectedIndex > 0){
            $('#sendBtn').prop('disabled', false);
        } else {
            $('#sendBtn').prop('disabled', true);
        }*/
    };
};

/** Send all data in the form back to sketchup callback handler */
function send_formdata(e){
    e.preventDefault();
    var formData = new FormData(document.getElementById('module-form'));
    var jsonData = extract_formdata_entries(formData);
    
    //var json = JSON.stringify(object);
    sketchup.send_to_layout(JSON.stringify(jsonData));
};

/** Reads and objectifies FormData entries */
function extract_formdata_entries(formData){
    var jsonData = {}
    for (var pair of formData.entries()) {
        console.log(pair[0]+ ', ' + pair[1]); 
        jsonData[pair[0]] = pair[1];
    }
    return jsonData;
}

/** ruby module sends over an array of all layout template files */
function set_template_options(json_array) {
    // do something with the value
    files = JSON.parse(json_array);

    var select = document.getElementById("templates_selectbox");
    files.forEach(el => {
        select.options[select.options.length] = new Option(el, el);
    });
};