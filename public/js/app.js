"use strict";
var whispers = {

  messages: {},

  init: function(){
    $('#whisper').on('submit', whispers.makeWhisper );
    whispers.ws = whispers.startSocket();
    whispers.checkMessages();
  },

  startSocket: function(){
    var ws = new WebSocket('wss://' + window.location.host + '/whisper');
    ws.onopen = function(){ whispers.refresh(); }; // show something
    ws.onclose = function(){ alert('Connection broken.'); }; // show something

    ws.onmessage = function(msg){
      if(msg.data === "/sent/"){
        whispers.pulse();
      } else if(msg.data.match(/\{/)){
        console.log(msg.data);
        var newMessages = $.parseJSON(msg.data);
        $.extend(whispers.messages, newMessages);
      } else {
        var pTag = $('<p>' + msg.data + '</p>');
        $('#gallery').prepend(pTag);
      }
    };

    return ws;
  },

  refresh: function(){
    whispers.ws.send("/refresh/");

    setTimeout(whispers.refresh, 6000);
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

  },

  checkMessages: function(){

    var secondsKey = Math.floor( new Date() / 1000 ).toString();
    var nowMessage = whispers.messages[secondsKey];

    if(nowMessage){
      var pTag = $('<p>' +
                 nowMessage +
                 '</p>');
      $('#gallery').prepend(pTag);

    whispers.messages[secondsKey] = undefined;
    delete whispers.messages[secondsKey];
    };

    setTimeout(whispers.checkMessages, 1000);
  }

};


$(document).ready( whispers.init );

