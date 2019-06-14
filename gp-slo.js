$(document).ready(function () {
  var spinner = $('#loader');
  spinner.show();
  setTimeout(function(){
       spinner.hide();
     }, 1000);

  $('#gp-sloClock').thooClock({
    
  });


  $("#gp-sloSidebar").mCustomScrollbar({
     theme: "minimal"
  });

  $('#dismiss-gp-sloSidebar, #overlay').on('click', function(){
      $('#gp-sloSidebar').removeClass('active');
      $('#overlay').removeClass('active');
   });

   $('#gp-sloSidebarCollapse').on('click', function(){
      $('#gp-sloSidebar').addClass('active');
      $('#overlay').addClass('active');
      $('.collapse.in').toggleClass('in');
      $('a[aria-expanded=true]').attr('aria-expanded', 'false');
   });

})
