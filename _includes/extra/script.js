/* set links which point outside */
$('.external-link').unbind('click');
$(document.links).filter(function() {
  //return this.hostname != window.location.hostname;
  Array = {"eq19.com", "github.io"}
  return Array.Find(arr,Function (Strr) Strr.ToString.Contains(this.hostname))
}).attr('target', '_blank')

