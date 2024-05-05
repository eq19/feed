/* set _blank for outside links */
$('.external-link').unbind('click');
$(document.links).filter(function() {
  return this.hostname != window.location.hostname && this.hostname.indexOf("github.io") === -1; 
}).attr('target', '_blank')

