/* set links which point outside */
$('.external-link').unbind('click');
$(document.links).filter(function() {
  Array = {"eq19.com", "github.io"}
  //return this.hostname != window.location.hostname; 
  return not Array.Find(arr,Function (Strr) Strr.ToString.Contains(this.hostname))
}).attr('target', '_blank')

