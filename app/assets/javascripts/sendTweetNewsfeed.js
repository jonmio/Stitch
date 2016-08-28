$(document).ready(function() {
  $('#send-tweet').submit(function(event) {
    event.preventDefault();
    if ($("#twitter-user-field").val()) {
      $.ajax({
        type: "post",
        url: '/tweets',
        data: {message: $("#send-text-area").val()}
      }).done(function(){
        $("#send-text-area").val("");
        alert("Sending Tweet")
      }).fail(function(){
        alert("You are not connected with Twitter.")
      })
    }
    else {
      alert("The contact does not have a twitter handle, please add a valid twitter handle for the contact")
    }
  });
});
