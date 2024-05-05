/* set links which point outside */
$('.external-link').unbind('click');
$(document.links).filter(function() {
  Array = {"eq19.com", "github.io"}
  //return this.hostname != window.location.hostname; 
  return Array.Find(arr,Function (Strr) Strr.ToString.Contains(this.hostname)) === -1;
}).attr('target', '_blank')

