jQ$.fn.sort = function() { 
  return this.pushStack( jQuery.makeArray( [].sort.apply( this, arguments )) ); 
};
Crabgrass.Tabs =  function() {
      return {
        create: function() {
          var self = {
            triggers : new Array( ),
            segments : new Array( ),
            segment_count: 0,
            add: function( element, trigger  ) {
                self.segments[ self.segment_count ] = element;
                self.triggers[ self.segment_count ] = trigger;
                jQ$(trigger).click( function(ev){ self.show(element); } ) ;
                ++self.segment_count;
                },
            show: function( element ) {
                var key = jQ$(self.segments).index( element );
                var trigger =  self.triggers[key];
                jQ$(self.segments).removeClass( 'active'); 
                console.log( self.segments[key].inspect() );
                console.log(jQ$(self.segments).not( self.segments[key]).is(":visible").length);
                if( jQ$(self.segments).not( self.segments[key]).is(":visible")) {
                  jQ$(self.segments).not( self.segments[key]).filter( ":visible" ).hide('slide', 
                    { duration: 150, direction: 'left',   
                      callback: function(){ 
                          jQ$(self.segments[key]).show('slide', 
                            { duration: 150, direction: 'right', 
                              callback: function() { jQ$(self.segments[key]).addClass( 'active'); } }) 
                        }} );
                } 
                jQ$(self.triggers).removeClass( 'active');
                jQ$(trigger).addClass( 'active');
              },
          };
          return self;
        },
        timestamp_sort: function(entry_a, entry_b){ 
          var time_a = jQ$('.friendly_date', entry_a).length;
          var time_b = jQ$('.friendly_date', entry_b).length;
          if(!(time_a||time_b)) return 0;
          if(!time_a) return 1;
          if(!time_b) return -1;
          var time_a = jQ$(".friendly_date", entry_a)[0].readAttribute('title');
          var time_b = jQ$(".friendly_date", entry_b)[0].readAttribute('title');
          return ( time_a > time_b ) ? -1 : ( ( time_a < time_b ) ?  1 : 0 );
        },
        initialize_tab_blocks: function( )  {
          jQ$("ul.tab-block").each( function() { 
            var ul = this;
            var ul_tabs = Crabgrass.Tabs.create();

            //disable inactive tabs
            jQ$('.tab-title + .tab-content:not(:has(li))', ul).prev().addClass('disabled');

            //copy all list entries to the "all" list
            var all_list = jQ$('.list-item', ul).clone().sort( Crabgrass.Tabs.timestamp_sort );

            // add the "all" block to the existing ul
            jQ$('.tab-content', ul).hide();
            all_list.prependTo( ul).wrapAll('<li><ul class="tab-content list active"></ul></li>').parent().before('<div class="tab-title">All</div>');

            var triggers = jQ$('.tab-title', jQ$(ul).children()).not('.disabled');
            var segments = triggers.next('.tab-content');

            //create tab-titlebar
            var titlebar = jQ$('.tab-title', ul).remove().prependTo(jQ$(ul)).wrapAll('<div class="tab-titlebar"></div>').parent();

            //move toolbar into titlebar
            jQ$('.toolbar.tabs-menu', ul).remove().appendTo( jQ$('tab-titlebar', ul));
  
            //var triggers = jQ$('.tab-title:not[.disabled]', ul);
            triggers.each( function() { 
                ul_tabs.add( segments[triggers.index(this)], this ); 
              } );

            //setup 'all' list as a tab
            jQ$(ul).addClass('active');
            ul_tabs.show( segments[0] );

            //add alternating color classes
            jQ$('.list-item:even', all_list).addClass('shade-even').removeClass('shade-odd');
            jQ$('.list-item:odd', all_list).addClass('shade-odd').removeClass('shade-even');
          } );
        }
      }
    }();
  //}
//}();


