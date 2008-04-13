Crabgrass.Tabs =  function() {
      return {
        create: function() {
          var self = {
            triggers : new Array( ),
            segments : new Array( ),
            segment_count: 0,
            add: function( element, trigger  ) {
                self.segments[ self.segment_count ] = $( element );
                self.triggers[ self.segment_count ] = $( trigger );
                Event.observe( $( trigger ), 'click', function( ){ self.show( $( element ) ); }, self ) ;
                ++self.segment_count;
                },
            show: function( element ) {
                var key = self.segments.indexOf( element );
                var trigger =  self.triggers[key];
                var to_check = self.segments.without(self.segments[key]);
                var items_to_hide = to_check.select( function( item ) { return item.visible(); } )
                
                if ( !( self.segments[key].visible() && items_to_hide.all( function(item){ return !item.visible(); } ) )) { 
                  self.segments.each( function(e) { e.removeClassName( 'active'); } );
                  jQuery(items_to_hide).hide('slide', { duration: 150, direction: 'left', callback: function(){ 
                    jQuery(self.segments[key]).show('slide', { duration: 150, direction: 'right', callback: function() { 
                        self.segments[key].addClassName( 'active');
                      } }) 
                    }} );
                }
                self.triggers.each( function( item ) { item.removeClassName( 'active');});
                trigger.addClassName( 'active');
              },
            collapse: function( ) {
                self.segments.each( function( item ) { if (item.visible()) new Effect.SwitchOff( item );});
              },
            expand: function( ) {
                self.segments.each( function( item ) { if (!item.visible()) new Effect.Appear( item );});
              }
          };
          return self;
        },
        initialize_tab_blocks: function( )  {
          $$("ul.tab-block").each( function(ul) { 
            var ul_tabs = Crabgrass.Tabs.create();

            //copy all list entries to the "all" list
            var all_list = document.createElement('ul');
            Element.extend(all_list);
            all_list.addClassName('tab-content list active');
            var sorted_entries = ul.select('.list-item').sortBy( function(entry){ 
              var timestamp = entry.down(".friendly_date");
              if(timestamp==null) return false;
              return timestamp.readAttribute('title');
              }).reverse();
            sorted_entries.each( 
                function(entry) { 
                  all_list.appendChild( entry.cloneNode(true) ); 
                } 
            );

            // add the "all" block to the existing ul
            ul.select('.tab-content').invoke('hide');
            var all_block = document.createElement('li');
            Element.extend( all_block );
            all_block.insert( all_list );
            ul.insert( { top: all_block } );

            //create tab-titlebar
            var titlebar = Element.extend( document.createElement('div'));
            titlebar.addClassName('tab-titlebar');
            ul.select('.tab-title').each( function(title) { //add tab-titles
                if( title.next('.tab-content') && title.next('.tab-content').down('li')) {
                  ul_tabs.add( title.next('.tab-content'), title );
                } else {
                  title.addClassName('disabled');
                }
                titlebar.appendChild( title.remove()); } 
            );
            ul.insert( { top: titlebar } );

            //add all tab-title
            var all_title = Element.extend( document.createElement('div') );
            all_title.addClassName('tab-title');
            all_title.insert('All');
            titlebar.insert( { top: all_title } );

            //move toolbar into titlebar
            ul.select('.toolbar').each( function(toolbar) { titlebar.insert( {bottom: toolbar.remove() } ) } );
  
            //setup 'all' list as a tab
            ul_tabs.add( all_list, all_title );
            ul.addClassName('active');
            ul_tabs.show( all_list );

            //add alternating color classes
            //ul.select('.tab-content').each( function( tab_contents ) { 
            new Array( all_list ).each( function( tab_contents ) { 
              tab_contents.select('.list-item:nth-child(odd)').each( 
                function( list_item ) { list_item.addClassName( "shade-odd" ); list_item.removeClassName('shade-even');  } );
              tab_contents.select('.list-item:nth-child(even)').each( 
                function( list_item ) { list_item.addClassName( "shade-even" ); list_item.removeClassName('shade-odd'); } );
            } );
          } );
        }
      }
    }();
  //}
//}();


