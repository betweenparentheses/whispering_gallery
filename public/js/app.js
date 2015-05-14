var listeners = {
  makeWhisper: function(){
    var words = document.getElementById('words');
    var para = document.createElement('p');
    var textNode = document.createTextNode(words.value);
    para.appendChild(textNode);

    document.getElementById('gallery').appendChild(para);
    words.value = "";
  }
};

var btn = document.getElementById('whisper-submit');

btn.addEventListener('click', listeners.makeWhisper);




// function poll() {
//   xhr = $.ajax({
//     url: '/messages/since/' + $('input#index').val(),
//     type: 'GET',
//     dataType: 'json',
//     success: function(data) {
//       if(data) {
//         $('input#index').val(data.index);
//         for(var i = 0; i < data.messages.length; i++) {
//           add(data.messages[i].name, data.messages[i].message);
//         }
//       }
//     },
//     error: function() {}
//   });
//   setTimeout(poll, 1000);
// }