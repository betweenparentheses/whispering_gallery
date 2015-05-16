"use strict";
var whispers = {

  messages: {},

  init: function(){
    $('#whisper').on('submit', whispers.makeWhisper );
    whispers.ws = whispers.startSocket();
    setTimeout(function(){
      whispers.ws.send("/refresh/");
    }, 600000);
  },

  startSocket: function(){
    var ws = new WebSocket('ws://' + window.location.host + '/whisper');
    ws.onopen = function(){ }; // show something
    ws.onclose = function(){ alert('Connection broken.'); }; // show something

    ws.onmessage = function(msg){
      if(msg.data === "/sent/"){
        whispers.pulse();
      } else if msg.data.match(/\{/) {
        whispers.messages = $.parseJSON(msg.data);
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

