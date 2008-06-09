Crabgrass.Forms = function() {
  var self = { 
    initialize_radio_behavior: function() {
      $$('input.behavior-radio').each( function(el){
        el.observe( 'click', function( ev ) {
          if( !el.getValue()) {
            ev.stop();
            return false;
          }
          el.up('.behavior-block').select( 'input.behavior-radio').without(el).each( function(elo) { 
            elo.checked = false;
          } );
        } );
      } );
    },
    submit_from_menu: function() {
      title_menu = $('titlebox').down('.toolbar.title-menu');
      delete_button = title_menu.down('input[type=submit].delete');
      if (delete_button != null ) { 
        delete_button.observe( 'click', function(ev) {
          if(!confirm("You are about to delete the current page.  You will not be able to undo this.")) {
            ev.stop();
            return;
          }
        });
      }
      if (title_menu == null ) return;
      form = $('content').down('.edit form');
      if ( form == null ) form = $('content').down('.new form');
      if ( form == null ) return;
      //submit_buttons = form.select("p.submit input[type=submit]").each( function( submit_button ) {
      submit_block = form.down("p.submit").cloneNode(true);
      submit_block.select('input[type=submit]').each( function( menu_submit ) {
        menu_submit.observe( 'click', function(ev) { form.submit(); } );
        //title_menu.insert( menu_submit );
      } );
      title_menu.insert( { top: submit_block } );
    },

    initialize_remote_actions: function() {
      $$('.behavior-block .remote').each( function(el) {
        el.observe( 'click', function(ev) {
          if( el != Event.element(ev)) {
            //ev.stop();
            return false;
          }
          //confirm action if so marked -- replace this someday with nicer text or undo options
          if( el.hasClassName('confirm')){ 
            data_to_delete = el.up('.row').select('select,input[type=text]').pluck( 'value' ).join("\n");
            confirm_message = "You are about to delete the following data:\n\n" + data_to_delete + "\n\n";
            if( !confirm(confirm_message+'Are you sure?')) {
              ev.stop();
              return false;
            }
          }
          //discover remote target
          if( !(remote_action = el.readAttribute('remote_url'))) { 
            if( !(remote_action = el.readAttribute('href'))) {
              return; 
            }
          } 

          request_options = { 
            asynchronous:true, 
            evalScripts:true, 
            method: 'get',
            onLoading: function(){ Crabgrass.Ajax.show_busy(el); }, 
            onComplete: function(){ Crabgrass.Ajax.hide_busy(el); },  
            onFailure: function( response ){ Crabgrass.Ajax.Message.show_error() ; }  
          };
          if (el.form) { 
            request_options.parameters= Form.serialize(el.form);
            request_options.method = 'post'
          }
          if(el.hasClassName('delete')) {
            request_options.onSuccess = function( response ){ self.delete_successful(el); };
            request_options.method = 'delete'
          }
          if(el.hasClassName('new')) {
            request_options.onSuccess = function( response ){ self.new_successful(el, response ); };
          }
          new Ajax.Request( remote_action, request_options);
          ev.stop();
        } );
      } );
    },

    delete_successful: function( el ) {
      to_delete = el.up('.row');
      if(to_delete) {
        new Effect.DropOut( to_delete );
        to_delete.byebye = to_delete.remove.bindAsEventListener( to_delete );
        setTimeout( to_delete.byebye , 1000 );
      }
    },

    new_successful: function( el, response ) {
      
      insert_block = new Element( 'div' ).update(response.responseText);
      insert_block.hide();
      
      el.up('.toolbar').insert( { before: insert_block } );
      new Effect.Appear( insert_block );
    }

    
  };
  return self;
}();

Crabgrass.Ajax = function() {
  var self = {
    Message: function() {
      var m_self = {
        display: function() {
          if (jQ$('#ajax-message').length == 0) {
           jQ$('<div id="ajax-message"></div>').appendTo( document.body ).hide()[0] ; 
          } 
          return jQ$('#ajax-message')[0];
        }(),

        show_error: function( message ) {
          if (message == null) {
            message = "Whoops...something went wrong.  Reload the page or try again later... "
          }
          m_self.show( message, 'error' );
        },

        show: function( message, message_class ) {
          if (message == null) {
            message = "Hello!";
          }
          if (message_class == null) message_class = 'message';

          //m_self.display.update( new Element('div', { 'class': message_class }).update( message ));
          jQ$(m_self.display).html( jQ$('<div></div>').addClass( message_class).text( message) )[0].show();
          m_self.set_position();
          
          m_self.onscroll = function() {  m_self.set_position(m_self) } ;
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
