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
      if (title_menu == undefined) return;
      $$('form').each( function( form ) {
        form.select("input[type=submit]").each( function( submit_button ) {
          menu_submit = submit_button.cloneNode(true);
          menu_submit.observe( 'click', function(ev) { form.submit(); } );
          title_menu.insert( menu_submit );
        } );
      } );
    },

    initialize_remote_actions: function() {
      $$('.behavior-block .remote').each( function(el) {
        el.observe( 'click', function(ev) {
          //confirm action if so marked -- replace this someday
          if( el.hasClassName('confirm') && !confirm('Are you sure?')) {
            ev.stop();
            return false;
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
        display: {},
        init: function() {
          if(!$('ajax-message'))  {
            m_self.display = new Element('div', { 'id': 'ajax-message' })
            document.body.insert( { bottom: m_self.display } );
            m_self.display.hide();
          }
        },

        show_error: function( message ) {
          if (message == undefined) {
            message = "Whoops...something went wrong.  Reload the page or try again later... "
          }
          m_self.show( message, 'error' );
        },

        show: function( message, message_class ) {
          if (message == undefined) {
            message = "Hello!";
          }
          if (message_class == undefined) message_class = 'message';

          m_self.display.update( new Element('div', { 'class': message_class }).update( message ));
          m_self.display.show();
          m_self.set_position();
          
          m_self.onscroll = m_self.set_position.bindAsEventListener(m_self);
          m_self.expire = m_self.hide.bindAsEventListener(m_self);
          Event.observe( window, 'scroll', m_self.onscroll );
          window.setTimeout( m_self.expire, 10000 );
        },

        hide: function() {
          m_self.display.hide();
          Event.stopObserving( window, 'scroll', m_self.onscroll);
        },

        set_position: function () {
          m_self.display.setStyle({ top: document.viewport.getScrollOffsets().top + 'px' } ) 
        }
      };
      m_self.init();
      return m_self;
    }(),

    show_busy: function( el ) {
      el = Element.extend( el );
      el.hide();
      if(!el.next() || !el.next().hasClassName('busy')) {
        el.insert( { after: new Element( 'div', { 'class': 'busy'} ) });
      } 
    },

    hide_busy: function( el ) {
      el = Element.extend( el );
      el.show();
      if(el.next() && el.next().hasClassName('busy')) {
        el.next().remove();
      }
    }
  };
  return self;
}();
