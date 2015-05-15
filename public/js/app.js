"use strict";
var whispers = {

  messages: {},

  init: function(){
    $('#whisper').on('submit', whispers.makeWhisper );
    whispers.pollServer();
    whispers.checkMessages();
  },


  makeWhisper: function(event){
    var words = $('#words');
    event.preventDefault();

    var xhr = $.ajax({
      url: '/send_message.json',
      type: 'POST',
      dataType: 'json',
      contentType: 'application/json',
      data: JSON.stringify({ message: words.val()}),
      success: function(data){
        console.log('added message: '+ data);
      },
      error: function(){
        alert('You did not speak');
      }
    });

    $(words).val('');
  },

  pollServer: function() {
    var xhr = $.ajax({
      url: '/poll_messages.json',
      type: 'GET',
      dataType: 'json',
      success: function(data) {
        if(data) {

          whispers.messages = {};
          data.forEach(function(msg){
            whispers.messages[msg.time] = msg.message;
          });
          console.log(data);
        };
      },
      error: function() {
        console.log('Polling failed!');
      }
    });

    // run again in 10 minutes
    setTimeout(whispers.pollServer, 600000);
  },

  checkMessages: function(){

    var seconds = Math.floor( new Date() / 1000 );
    var nowMessage = whispers.messages[seconds];

    if(nowMessage){
      var pTag = $('<p>' +
                 nowMessage +
                 '</p>');
      $('#gallery').prepend(pTag);

    delete whispers.messages[seconds];
    };


    setTimeout(whispers.checkMessages, 1000);
  }

};


$(document).ready( whispers.init );

