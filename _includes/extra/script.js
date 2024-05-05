/* set _blank for outside links */
$('.external-link').unbind('click');
$(document.links).filter(function() {
  return this.hostname != window.location.hostname; 
}).attr('target', '_blank')

