jQ$.fn.sort = function() { 
  return this.pushStack( jQuery.makeArray( [].sort.apply( this, arguments )) ); 
};
jQ$.fn.activate = function( base_class ) { 
  if ( base_class !== undefined ) { jQ$(this).addClass( base_class+'-active'); }
  return jQ$(this).addClass('active');
};
jQ$.fn.deactivate = function( base_class ) { 
  if ( base_class !== undefined ) { jQ$(this).removeClass( base_class+'-active'); }
  return jQ$(this).removeClass('active');
};

if( Crabgrass === undefined ) { var Crabgrass = function() { return { }; }; }
Crabgrass.Tabs =  function() {
  return {
    create: function( self ) {
      // this private method adds tab methods to DOM elements
      var _extend_tab = function( tab, trigger, ul ) {
        jQ$.extend( tab, {
          trigger: trigger,
          tabset: ul,
          transition_in: function() {
              if ( tab.trigger !== undefined ) {
                if(!jQ$(tab.trigger).is('.active')) { jQ$(tab.trigger).activate('tab-title'); }
              }
              if(!jQ$(tab).is(':visible')) {
                if(jQ$(tab).is('.active')) { jQ$(tab).deactivate('tab-content'); }
                jQ$(tab).show('slide', 
                  { duration: 500, 
                    direction: 'right', 
                    callback: function() { jQ$(tab).activate('tab-content'); }
                  });
              } 
            },
          show: function() { 
            if(jQ$(tab).is(':visible')) { return tab.transition_in(); }

            ul.tabs.deactivate('tab-content');
            ul.triggers.deactivate('tab-title');
            ul.transition_to( tab );

          }
        } );
      };

      //disable tabs without content
      jQ$('.tab-title:not(:first) + .tab-content:not(:has(li))', self).prev().addClass('disabled');

      //establish a list of active tab-triggers
      var triggers = jQ$('.tab-title:not(.disabled)', self );
      if ( triggers.length === 0 ) { 
        var tabs = jQ$('.tab-content:has(li)', self);
      } else {
        var tabs = triggers.next('.tab-content'); 
      }

      // some methods for the ul container
      var container_extensions = { 
          tabs: tabs,
          triggers: triggers,
          activate: function() {
            if( self.tabs.length === 0 ) { return; }
            self.tabs[0].show();
            jQ$(self.tabs[0]).activate('tab-content');
            jQ$(self).activate('tab-block');
          },
          transition_to: function( new_tab ) { 
            self.tabs.filter(':visible').not(new_tab).hide('slide', 
            { duration: 500, 
              direction: 'left',   
              callback: new_tab.transition_in
                } );
          }
        };

      jQ$.extend( self, container_extensions );

      //extend triggers and tabs
      jQ$(self.triggers).each( function() { 
          var tab = jQ$(this).next('.tab-content')[0];
          _extend_tab( tab, this, self );
          jQ$.extend( this, { tab: tab }); 
        } );
      if ( self.triggers.length == 0 ) {
        jQ$(self.tabs).each( function() { 
//          if( this.trigger !== undefined ) { return; }
          _extend_tab( this, undefined, self );
        } );
      }
      return self;
    },

    create_all_block: function( ul ) {
      //timestamp sorting is used to order the all block
      var timestamp_sort = function(entry_a, entry_b){ 
        var time_a = jQ$('.friendly_date', entry_a).length;
        var time_b = jQ$('.friendly_date', entry_b).length;

        //i miss the spaceship operator
        //checking if either item has no date
        if(!(time_a||time_b)) { return 0; }
        if(!time_a) { return 1; }
        if(!time_b) { return -1; }

        time_a = jQ$(".friendly_date", entry_a).eq(0).attr('title');
        time_b = jQ$(".friendly_date", entry_b).eq(0).attr('title');

        //i miss the spaceship operator
        //comparing the dates
        return ( time_a > time_b ) ? -1 : ( ( time_a < time_b ) ?  1 : 0 );
      };

      //copy all list entries to the "all" list
      var all_list = jQ$('.list-item', ul).clone().sort( timestamp_sort );

      //add alternating color classes
      jQ$('.list-item:even', all_list).addClass('shade-even').removeClass('shade-odd');
      jQ$('.list-item:odd', all_list).addClass('shade-odd').removeClass('shade-even');

      // add the "all" block to the existing ul
      jQ$('.tab-content', ul).hide();
      all_list.prependTo( ul).wrapAll('<li><ul class="tab-content list active tab-content-active"></ul></li>').parent().before('<div class="tab-title">All</div>');

    },

    create_tab_bar: function( ul ) {
      //create tab-titlebar
      jQ$('.tab-title', ul).remove().prependTo(jQ$(ul)).wrapAll('<div class="tab-titlebar"></div>').parent().click( function(ev) { if (ev.target.tab !== undefined ) { ev.target.tab.show(); } } ) ;

      //move toolbar into titlebar
      jQ$('.toolbar.tabs-menu', ul).remove().appendTo( jQ$('tab-titlebar', ul));

    },

    initialize_tab_blocks: function( )  {
      jQ$("ul.tab-block").each( function() { 

        if( jQ$(this).is(':not(.no-all-block)')) { 
           Crabgrass.Tabs.create_all_block( this ); 
        } else {
          jQ$('.tab-content:not(:first)', ul).hide();
        }
        //Crabgrass.Tabs.create_all_block( this );
        var ul = Crabgrass.Tabs.create(this);

        Crabgrass.Tabs.create_tab_bar( this );
        //activate list and 1st tab
        ul.activate();

      } );
    }
  };
}();


