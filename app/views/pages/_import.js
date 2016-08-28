$(function() {
    $.ajax({
      method: "GET",
      url: "/import_contacts.json",
      datatype: "json"
    }).done(function(response){
      console.log(response)
      window.all_contacts = response ? response : []
      response.forEach(load_imported_contacts);
      clickable();
    });

    $("#search_imported_contacts").on("submit",function(event){
      event.preventDefault();
    });

    $(".import-search-bar").keyup(function(){
      var query= $(".import-search-bar").val()
      duplicated_elements(query)
      $(".potential-contacts-container").html("")
      window.all_contacts.forEach(load_imported_contacts);
      clickable();

    });

    $("#import_contact_button").click(function(e){
      $("#import_contact_button").attr('id',"");
      e.preventDefault()
      window.all_contacts.forEach(function(contact){
        if (contact.selected === true){
          contact.category = 'friend'

          $.ajax({
              url:"/contacts",
              method:"post",
              data: {contact: contact}
            })
        }
      })

      if ($(".selected").length === 0){
        window.location.replace("/link_to_twitter")
      }
      else {
        $(document).ajaxStop(function () {
          window.location.replace("/link_to_twitter")
        });
      }
    })

});

function clickable(){
  $(".potential-contacts").click(function(e){
    index = $(this).attr("id")
    $(this).toggleClass("selected")
    var state = window.all_contacts[index].selected
    if (state === true){
      window.all_contacts[index].selected = false
      $('.number_of_selected_contacts').text(parseInt($('.number_of_selected_contacts').text())-1)
    }
    else {
      window.all_contacts[index].selected = true
      $('.number_of_selected_contacts').text(parseInt($('.number_of_selected_contacts').text())+1)

    }

  })
}


function load_imported_contacts(contact, index){
  if ( (contact.show === true) && (contact.selected === false) ){
    if (contact.name !== "") {
      $(".potential-contacts-container").append("<div id="+ index+ " class='potential-contacts'><h2 class='potential-contact-name'>"+contact.name+"</h2><h4 class='potential-contact-email'>"+contact.email+"</h4></div>")
    }
    else if (contact.email) {
      $(".potential-contacts-container").append("<div id="+ index + " class='potential-contacts'><h2 class='potential-contact-name'>"+contact.email.split("@")[0]+"</h2><h4 class='potential-contact-email'>"+contact.email+"</h4></div>")
      var contact_name = contact.email.split("@")[0]
      update_all_contacts(contact.email, contact_name)
    }
    else{
      $(".potential-contacts-container").append("<div id="+ index+ " class='potential-contacts'><h2 class='potential-contact-name'>"+"No Name"+"</h2><h4 class='potential-contact-email'>"+contact.email+"</h4></div>")
    }
  }
  else if (contact.show === true) {
    if (contact.name !== "") {
      $(".potential-contacts-container").append("<div id="+ index+ " class='potential-contacts selected'><h2 class='potential-contact-name'>"+contact.name+"</h2><h4 class='potential-contact-email'>"+contact.email+"</h4></div>")
    }
    else if (contact.email) {
      $(".potential-contacts-container").append("<div id="+ index + " class='potential-contacts selected'><h2 class='potential-contact-name'>"+contact.email.split("@")[0]+"</h2><h4 class='potential-contact-email'>"+contact.email+"</h4></div>")
      var contact_name = contact.email.split("@")[0]
      update_all_contacts(contact.email, contact_name)
    }
    else{
      $(".potential-contacts-container").append("<div id="+ index+ " class='potential-contacts selected'><h2 class='potential-contact-name'>"+"No Name"+"</h2><h4 class='potential-contact-email'>"+contact.email+"</h4></div>")
    }
  }
}

function update_all_contacts(contact_email, contact_name) {
  window.all_contacts.forEach(function(contact){
    if (contact['email'] === contact_email) {
      contact['name'] = contact_name
    }
  })
}

function duplicated_elements(searchterm){

    window.all_contacts.forEach(function(contact){
      if (isSubstring(searchterm, contact)){
        contact.show = true
      }
      else {
        contact.show = false
      }
    })
}
