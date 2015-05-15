"use strict";
var whispers = {

  messages: {},

  init: function(){
    $('#whisper').on('submit', whispers.makeWhisper );
    // whispers.pollServer();
    // whispers.checkMessages();
    whispers.ws = whispers.startSocket();

  },

  startSocket: function(){
    var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
    ws.onopen = function(){ }; // show something
    ws.onclose = function(){ }; // show something

    ws.onmessage = function(msg){
      if(msg.data === "*WHISPER SENT*"){
        whispers.pulse();
      } else {
        var pTag = $('<p>' + msg.data + '</p>');
        $('#gallery').prepend(pTag);
      }
    };

    return ws;
  },

  pulse: function(){
    $('body').addClass('pulse');
    setTimeout(function(){
      $('body').removeClass('pulse');
    }, 500);
  },

  makeWhisper: function(event){
    event.preventDefault();
    var words = $('#words');

    whispers.ws.send(words.val());
    $(words).val('');

  }

};


$(document).ready( whispers.init );

