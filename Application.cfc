component {
	//systemOutput("Application Received #cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#", true);
	function onApplicationStart() {
		cfthread( name="produceData", action="run" ) {
			thread.ws = new WebSocket();
			sleep( 10000 );
			while( true ) {
				try {
					sleep( 500 );
					thread.ws.send( "server-time", dateTimeFormat( now(), "full" ) )
					sleep( 500 );
					thread.ws.send( "lucky-numbers", randRange( 1, 1000 ) )
				} catch( any e ) {
					e.printStackTrace();
				}
			}
		}
	}
}