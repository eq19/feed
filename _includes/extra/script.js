/* set links which point outside */
$('.external-link').unbind('click');
$(document.links).filter(function() {
  //return this.hostname != window.location.hostname; 
  Array = {"eq19.com", "github.io", window.location.hostname};
  return Array.Find(arr,Function (Strr) Strr.ToString.indexOf(this.hostname)) === -1;
}).attr('target', '_blank')

