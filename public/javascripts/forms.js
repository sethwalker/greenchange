if( Crabgrass === undefined ) { var Crabgrass = function() { return { }; }; }
Crabgrass.Forms = function() {
  var self = { 
    initialize_radio_behavior: function() {
      jQ$('input.behavior-radio').click( function(ev) {
          jQ$( 'input.behavior-radio', jQ$(this).parents('.behavior-block')).not(this).each( function() { 
              jQ$(this).attr('checked', false);
            } );
          if( !jQ$(ev.target).attr( 'checked' )) { return false; }
        });
    },
    submit_from_menu: function() {
      var title_menu = jQ$('#titlebox .toolbar.title-menu');
      if( title_menu.length === 0 ){ return; }
      jQ$('input[type=submit].delete', title_menu).click( function(ev) {
          if(!confirm("You are about to delete the current page.  You will not be able to undo this.")) { return false; }
        });
      var form = jQ$('.edit form, .new form', "#content" )[0];
      if( form !== undefined ) {
        jQ$( 'input[type=submit]', jQ$( 'p.submit', form ).clone().prependTo( title_menu )).click( function(ev) { form.submit(); });
      }
    },

    initialize_remote_actions: function() {
      jQ$('.behavior-block .remote').click( function(ev) {
        if( this != ev.target ){ return false; }
        var remote_action = jQ$(ev.target).attr('remote_url') || jQ$(ev.target).attr('href');
        if( !remote_action ){ return; }

        if( jQ$(ev.target).is('.confirm')) {
          var data_to_delete = jQ$( 'select,input[type=text]', jQ$(ev.target).parents('.row')).map( function() { return jQ$(this).val(); }).get().join('\n');
          var confirm_message = "You are about to delete the following data:\n\n" + data_to_delete + "\n\n";
          if( !confirm(confirm_message+'Are you sure?')) { return false; }
        }
        request_options = { 
          url: remote_action,
          beforeSend: function(){ Crabgrass.Ajax.show_busy(ev.target); }, 
          complete: function(){ Crabgrass.Ajax.hide_busy(ev.target); },  
          error: function( response ){ Crabgrass.Ajax.Message.show_error(); },
          data: {}
        };
        if(jQ$(ev.target).is('.delete')) {
          //html datatype prevents jQuery from throwing xml parse error
          request_options.dataType = 'html';
          request_options.data._method =  'delete';
          request_options.success = function( ){ self.delete_successful(ev.target); };
          request_options.type = 'POST';
        }
        if(jQ$(ev.target).is('.new')) {
          request_options.success = function( response ){ self.new_successful(ev.target, response ); };
        }
        jQ$.ajax( request_options );
        return false;

        
      });
    },

    delete_successful: function( el ) {
      jQ$(el).parents().filter('.row').eq(0).hide('drop', { direction: 'down', duration: 400, callback: function() { this.remove(); } } );
    },

    new_successful: function( el, response ) {
      jQ$(response).hide().insertBefore( jQ$(el).parents('.toolbar').parents('.row').eq(0)).show('drop', { direction: 'up' });
    }

    
  };
  return self;
}();

Crabgrass.Ajax = function() {
  var self = {
    Message: function() {
      var m_self = {
        display: function() {
          if (jQ$('#ajax-message').length === 0) {
           jQ$('<div id="ajax-message"></div>').appendTo( document.body ).hide(); 
          } 
          return jQ$('#ajax-message')[0];
        }(),

        show_error: function( message ) {
          if (message === null) {
            message = "Whoops...something went wrong.  Reload the page or try again later... ";
          }
          m_self.show( message, 'error' );
        },

        show: function( message, message_class ) {
          if (message === null) {
            message = "Hello!";
          }
          if (message_class === null) { message_class = 'message'; }

          //m_self.display.update( new Element('div', { 'class': message_class }).update( message ));
          jQ$(m_self.display).html( jQ$('<div></div>').addClass( message_class).text( message) )[0].show();
          m_self.set_position();
          
          m_self.onscroll = function() {  m_self.set_position(m_self); } ;
          jQ$(window).scroll( m_self.set_position );
          window.setTimeout( m_self.hide, 10000 );
        },

        hide: function() {
          m_self.display.hide();
          jQ$(window).unbind('scroll', m_self.set_position );
        },

        set_position: function () {
          jQ$(m_self.display).css({ top: jQ$(document).scrollTop()});
        }
      };
      return m_self;
    }(),

    show_busy: function( el ) {
      jQ$(el).hide();
      if(!jQ$(el).next().is('.busy')) {
        jQ$(el).after( jQ$('<div class="busy"></div>'));
      } 
    },

    hide_busy: function( el ) {
      jQ$(el).show().next('.busy').remove();
    }
  };
  return self;
}();
