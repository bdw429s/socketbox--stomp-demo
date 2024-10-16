component {

	this.name = "WebSocket Stomp Demo";
	this.sessionManagement = true;

	// A random list of fruit
	fruit = [
		"apple",
		"banana",
		"cherry",
		"date",
		"elderberry",
		"fig",
		"grape",
		"honeydew",
		"kiwi",
		"lemon",
		"mango",
		"nectarine",
		"orange",
		"pear",
		"quince",
		"raspberry",
		"strawberry",
		"tangerine",
		"ugli",
		"vanilla",
		"watermelon",
		"yam",
		"zucchini"
	];

	// A random list of snacks
	snacks = [
		"pizza",
		"chips",
		"pretzels",
		"popcorn",
		"cookies",
		"brownies",
		"cake",
		"pie",
		"ice cream",
		"chocolate",
		"cheese",
		"crackers",
		"nuts",
		"candy",
		"donuts",
		"muffins",
		"cupcakes",
		"pudding",
		"jelly",
		"jelly beans",
		"marshmallows",
		"toffee",
		"taffy"
	];

	//systemOutput("Application Received #cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#", true);
	function onApplicationStart() {
		variables.ws = new WebSocket();
		// Spin up a daemon thread to sit in the background and crank out data for our clients to subscribe to
		cfthread( name="produceData", action="run" ) {
			setting requestTimeout=99999999999;
			sleep( 1000 );
			thread.ws = variables.ws;
			while( true ) {
				try {
					sleep( 250 );
					// Send current time
					thread.ws.send( "direct/server-time", dateTimeFormat( now(), "full" ) )
					sleep( 250 );
					// Send lucky number
					// We've left off the "direct/", but that is the default exchange so it works the same as the server-time example
					thread.ws.send( "lucky-numbers", randRange( 1, 1000 ) )
					sleep( 250 );
					// Send random fruit
					thread.ws.send( "topic/food.fruit", { 'food' : chooseRandom( fruit ), 'type' : 'fruit' } )
					sleep( 250 );
					// Send random snack
					thread.ws.send( "topic/food.snacks", { 'food' : chooseRandom( snacks ), 'type' : 'snack' } )
				} catch( any e ) {
					writedump( var=e.message, output="console" );
					writedump( var=e, output="console" );
				}
			}
		}
	}

	/**
	 * Helper function for choosing random item from an array.
	 */
	private function chooseRandom( required array list ) {
		return( list[ randRange( 1, arrayLen( list ) ) ] );
	}
}