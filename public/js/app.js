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