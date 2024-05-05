/* set _blank for outside links */
$('.external-link').unbind('click');
$(document.links).filter(function() {
  return this.hostname != window.location.hostname && not this.hostname.Contains("github.io"); 
}).attr('target', '_blank')

