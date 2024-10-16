/**
 * I am the STOMP WebSocket handler for this app.  
 * I extend the WebSocketSTOMP core class, so I expect to be communicating with a Stomp.js library on the client.
 */
component extends="modules.socketbox.models.WebSocketSTOMP" {
	
	// Some random message to reply to pings
	pongMessages = [
		"PONG!",
		"Pongsy",
		"Pongsalot",
		"Get off my lawn!",
		"Go away!",
		"Hey, I'm trying to work here!",
		"Stop it!",
		"Yeah, I'm still here",
		"You again?",
		"Stop pinging me!",
		"...",
		"This is feeling like a one-sided conversation",
		"Are you still there?",
		"Hello?",
		"Is this thing on?",
		"Testing, testing, 1, 2, 3"
	];

	// Some random messages to send to the family
	familyMessages = [
		"Family meeting in the living room!",
		"Family dinner tonight!",
		"Who left the back door open?",
		"Who left the front door open?",
		"32 shopping days left until Christmas",
		"Who left the milk out?",
		"Everyone OK with pizza for dinner?"
	];

	// Some random messages to send to the parents
	parentMessages = [
		"Parent date night tonight!",
		"Parent meeting in the kitchen!",
		"The kid's Christmas presents are hidden in the attic",
		"Time to pick up the kids from school",
		"Wedding anniversary tomorrow!",
		"Time to pay the electric bill",
		"We need to buy milk"		
	];

	// Some random messages to send to the kids
	kidMessages = [
		"Time for bed!",
		"Do your homework",
		"Clean your room",
		"Time to brush your teeth",
		"Go ride your bikes, it's nice outside!",
		"Don't tell mom we broke her favoriate vase!",
		"Let's get up early Saturday to watch cartoons",
		"Who wants to go to the skate park?",
		"Don't go in your siblings' room without permission"		
	];

	// Some random chores to assign to the family
	familyChores = [
		"Take out the trash",
		"Clean the bathroom",
		"Vacuum the living room",
		"Clean the kitchen",
		"Pick up the dog poop",
		"Mow the lawn",
		"Walk the pet alligator",
		"Wash the dishes",
		"Fold the laundry",
		"Wash the car",
		"Check the mail"
	];

	/**
	 * Here we configure our exchanges, listeners, and settings.
	 * This method will only be run once when the server starts UNLESS `debugMode` is set to `true`.
	 */
	function configure() {
		return {
			// Set to try (dynamically if you wish) to reload the config on EVERY request (for development only!)
			"debugMode" : false,
			// How often to send a heartbeat to the client (in milliseconds)
			"heartBeatMS" : 10000,
			// Here we configure the exchanges and their bindings which will process incoming messages.
			// Remember, all messages are send first to an exchange for routing.
			// The DirectExchange will be configured automatically even if we don't include it below.  It's default use require on special config.
			"exchanges" : {
				// Topic exchange routes messages based on a pattern match to their incoming destination
				 "topic" : {
				 	"bindings" : {
						// * matches exactly one word, so incoming messages named "topic/food.<anything>"" will be routed to consumers subscribing to the "all-food" destination
						"food.*" : "all-food",
						// These two are exact matches, which honestly could have been configured via the direct exchange, but we'll keep them all here.
						// incoming messages with the destination "topic/food.fruit" will be routed to consumers subscribing to the "only-fruit" destination
						"food.fruit" : "only-fruit",
						// incoming messages with the destination "topic/food.snacks" will be routed to consumers subscribing to the "only-snacks" destination
						"food.snacks" : "only-snacks"
					}
				},
				// Fanout exchange routes messages to all bound destinations
				"fanout" : {
					"bindings" : {
						// incoming messages with the destination "fanout/all-family" will be routed to all consumers subscribing to mom, dad, susie, or timmy
						"all-family" : [ "mom", "dad", "susie", "timmy" ],
						// incoming messages with the destination "fanout/all-parents" will be routed to all consumers subscribing to mom or dad
						"all-parents" : [ "mom", "dad" ],
						// incoming messages with the destination "fanout/all-kids" will be routed to all consumers subscribing to susie or timmy
						"all-kids" : [ "susie", "timmy" ]
					}
				},
				// Distribution exchange routes messages to a single destinations at a time in a round-robin or random fashion
				"distribution" : {
					// roundrobin or random
					"type" : "roundrobin",
					"bindings" : {
						// incoming messages with the destination "distribution/distribute-family" will be routed to mom, dad, susie, or timmy in a round-robin fashion
						"distribute-family" : [ "mom", "dad", "susie", "timmy" ]
					}
				}
			},
			// Our Websocket clients can create subscriptions to destinations, but we can also define server-side listeners
			"subscriptions" : {				
				// When a message is routed to "ping", we'll reply with a random pong message
				"ping" : (message)=>{
					// Get the reply-to destination from the message headers. This ensures only the original sender gets the reply.
					// The reply-to will be unique to each session, and our authorize() method ensure no other connection can subscribe to it.
					var relyDestination = message.getHeader( "reply-to", "" );
					if( len( relyDestination ) ) {
						send(
							relyDestination,
							chooseRandom( pongMessages ),
							{
								// If more than one message is sent, this is the convention for matching them back up on the client side
								// The client would need to supply the correlation-id header when sending the original message and we simply return it in the reply
								"correlation-id" : message.getHeader( "correlation-id", "" )
							}
						);
					}
				},
				// When a message is routed to "family-broadcast", we'll send a random family message to all family members.
				// This message will have reached here via the direct exchange, and we'll be sending it back out via the fanout exchange.
				"family-broadcast" : (message)=>{
					send(
						"fanout/all-family",
						chooseRandom( familyMessages ),
						{
							"correlation-id" : message.getHeader( "correlation-id", "" )
						}
					);
				},
				// When a message is routed to "parent-broadcast", we'll send a random parent message to all parents.
				"parent-broadcast" : (message)=>{
					send(
						"fanout/all-parents",
						chooseRandom( parentMessages ),
						{
							"correlation-id" : message.getHeader( "correlation-id", "" )
						}
					);
				},
				// When a message is routed to "kid-broadcast", we'll send a random kid message to all kids.
				"kid-broadcast" : (message)=>{
					send(
						"fanout/all-kids",
						chooseRandom( kidMessages ),
						{
							"correlation-id" : message.getHeader( "correlation-id", "" )
						}
					);
				},
				// When a message is routed to "family-chores", we'll send a random chore to a family member in a round-robin fashion.
				// This message will have reached here via the direct exchange, and we'll be sending it back out via the distribution exchange.
				"family-chores" : (message)=>{
					send(
						"distribution/distribute-family",
						chooseRandom( familyChores ),
						{
							"correlation-id" : message.getHeader( "correlation-id", "" )
						}
					);
				}
			}
		};
	}

	/**
	 * Here we decide who can authenticate to our websocket. The username and passcode provided in the JS connect request will be passed to this method.
	 * A hard-coded username and password in JavaScript isn't very secure, so you can also pass something like a JWT (JSON Web Token) that your app manages.
	 * Alternatively, you can just use the session scope!  All cookies will be passed from the browser, so your users's session scope will be available here to
	 * confirm who they are.
	 * 
	 * Note, this method does not handle what topics they can subscribe to to pubish messages.  This ONLY handles authentication.  i.e., can they log in use the system?
	 * 
	 * If you want to customize the reason message for an authentication failure, you can throw an exception with the type "STOMP-Authentication-failure" with a costom message.
	 * 
	 * @login The username or token provided by the client
	 * @passcode The password or token provided by the client
	 * @host The host the client is connecting from
	 * @channel The channel object for the connection
	 * 
	 * @return boolean (true if they can authenticate, false if they cannot).
	 */
	boolean function authenticate( required string login, required string passcode, string host, required channel ) {
		// Your custom logic here.  This is a demo, so it's open to anyone without a login.  
		// This method could have actually just been omitted, but it's here for the sake of the example.
		return true;
	}

	/**
	 * Once a user is authenticated, we can authorize them to subscribe to specific destinations.  This is where you can control what topics they can subscribe to
	 * and/or publish message to.  This method is only called for remote clients.  Code running on the server can subscribe to any destination.
	 * 
	 * If you want to customize the reason message for an authorization failure, you can throw an exception with the type "STOMP-Authorization-failure" with a costom message.
	 * 
	 * @login The username or token provided by the client when they authenticated
	 * @exchange The exchange the client is trying to subscribe or publish to (direct, topic, fanout, distribution, etc)
	 * @destination The destination the client is trying to subscribe or publish to.  
	 * @access The type of access the client is trying to get. "read" if they are subscribing and "write" if they are publishing.
	 * @channel The channel object for the connection
	 * 
	 * @return boolean (true if they can subscribe or publish, false if they cannot)
	 */
	boolean function authorize( required string login, required string exchange, required string destination, required string access, required channel ) {
		// We want the sessionID for this connection, so we'll get the details about this channel's connection
		var connectionDetails = getConnectionDetails( channel );
		var sessionID  	 = connectionDetails[ "sessionID" ] ?: '';

		// Only let people subscribe to their own ping/pongs
		if( destination.lcase().startsWith( 'pong.' ) && destination != "pong." & sessionID ) {
			// Alternatively, just return false for a default failure message
			throw( type="STOMP-Authorization-failure", message="You can only subscribe to your own session's pings." );
		}

		// Everything else is OK
		return true;
	}

	/**
	 * Helper function for choosing a random item from an array
	 */
	private function chooseRandom( required array list ) {
		return( list[ randRange( 1, arrayLen( list ) ) ] );
	}

}