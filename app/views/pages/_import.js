//all_contacts is an array of contacts containg information and boolean fields (visible and selected)
$(function() {
    $.ajax({
      method: "GET",
      url: "/import_contacts.json",
      datatype: "json"
    }).done(function(response){
      window.all_contacts = response
      response.forEach(load_imported_contacts);
      //bind contact to event listener
      clickable();
    });

    $("#search_imported_contacts").on("submit",function(event){
      event.preventDefault();
    });


    $(".import-search-bar").keyup(function(){
      var query= $(".import-search-bar").val()
      match_searchterm_with_contacts(query)
      $(".potential-contacts-container").html("")
      window.all_contacts.forEach(load_imported_contacts);
      clickable();

    });


    $("#import_contact_button").click(function(e){
      $("#import_contact_button").attr('id',"");
      e.preventDefault()
      //create route that can create multiple contacts
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
  //refactor pls
  if ( (contact.show === true) && (contact.selected === false) ){
    if (contact.name !== "") {
      $(".potential-contacts-container").append("<div id="+ index+ " class='potential-contacts'><h2 class='potential-contact-name'>"+contact.name+"</h2><h4 class='potential-contact-email'>"+contact.email+"</h4></div>")
    }
    else if (contact.email) {
      $(".potential-contacts-container").append("<div id="+ index + " class='potential-contacts'><h2 class='potential-contact-name'>"+contact.email.split("@")[0]+"</h2><h4 class='potential-contact-email'>"+contact.email+"</h4></div>")
      var contact_name = contact.email.split("@")[0]
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
    }
    else{
      $(".potential-contacts-container").append("<div id="+ index+ " class='potential-contacts selected'><h2 class='potential-contact-name'>"+"No Name"+"</h2><h4 class='potential-contact-email'>"+contact.email+"</h4></div>")
    }
  }
}



function match_searchterm_with_contacts(searchterm){

    window.all_contacts.forEach(function(contact){
      if (isSubstring(searchterm, contact)){
        contact.show = true
      }
      else {
        contact.show = false
      }
    })
}
