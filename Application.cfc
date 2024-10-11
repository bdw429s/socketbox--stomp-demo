component {

	//println( "Application.cfc loaded #cgi.SCRIPT_NAME#?#cgi.QUERY_STRING# in thread: #createOBject('java','java.lang.Thread').currentThread().getName()#" );

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

	// unhealthy snacks
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
		cfthread( name="produceData", action="run" ) {
			thread.ws = new WebSocket();
			sleep( 1000 );
			while( true ) {
				try {
					sleep( 250 );
					thread.ws.send( "direct/server-time", dateTimeFormat( now(), "full" ) )
					sleep( 250 );
					// same as direct (default)
					thread.ws.send( "lucky-numbers", randRange( 1, 1000 ) )
					sleep( 250 );
					thread.ws.send( "topic/food.fruit", { 'food' : chooseRandom( fruit ), 'type' : 'fruit' } )
					sleep( 250 );
					thread.ws.send( "topic/food.snacks", { 'food' : chooseRandom( snacks ), 'type' : 'snack' } )
				} catch( any e ) {
					e.printStackTrace();
				}
			}
		}
	}

	function chooseRandom( required array list ) {
		return( list[ randRange( 1, arrayLen( list ) ) ] );
	}
}