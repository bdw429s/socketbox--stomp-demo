component extends="modules.socketbox.models.WebSocketSTOMP" {
	
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

	familyMessages = [
		"Family meeting in the living room!",
		"Family dinner tonight!",
		"Who left the back door open?",
		"Who left the front door open?",
		"32 shopping days left until Christmas",
		"Who left the milk out?",
		"Everyone OK with pizza for dinner?"
	];

	parentMessages = [
		"Parent date night tonight!",
		"Parent meeting in the kitchen!",
		"The kid's Christmas presents are hidden in the attic",
		"Time to pick up the kids from school",
		"Wedding anniversary tomorrow!",
		"Time to pay the electric bill",
		"We need to buy milk"		
	];

	kidMessages = [
		"Time for bed!",
		"Do your homework",
		"Clean your room",
		"Time to brush your teeth",
		"Go ride your bikes, it's nice outside!",
		"Don't tell mom we broke her favoriate vase!",
		"Let's get up early Saturday to watch cartoons",
		"Who wants to go to the skate park?",
		"Don't go in your siblings' room without permission",
		
	];

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

	function configure() {
		return {
			"debugMode" : false,
			"heartBeatMS" : 0,
			"exchanges" : {
				 "topic" : {
				 	"bindings" : {
						"food.*" : "all-food",
						"food.fruit" : "only-fruit",
						"food.snacks" : "only-snacks"
					}
				},
				"fanout" : {
					"bindings" : {
						"all-family" : [ "mom", "dad", "susie", "timmy" ],
						"all-parents" : [ "mom", "dad" ],
						"all-kids" : [ "susie", "timmy" ]
					}
				},
				"distribution" : {
					"type" : "roundrobin",
					"bindings" : {
						"distribute-family" : [ "mom", "dad", "susie", "timmy" ]
					}
				}
			},
			"subscriptions" : {				
				"ping" : (message)=>{
					var relyDestination = message.getHeader( "reply-to", "" );
					if( len( relyDestination ) ) {
						send(
							relyDestination,
							chooseRandom( pongMessages ),
							{
								"correlation-id" : message.getHeader( "message-id", "" )
							}
						);
					}
				},
				"family-broadcast" : (message)=>{
					send(
						"fanout/all-family",
						chooseRandom( familyMessages ),
						{
							"correlation-id" : message.getHeader( "correlation-id", "" )
						}
					);
				},
				"parent-broadcast" : (message)=>{
					send(
						"fanout/all-parents",
						chooseRandom( parentMessages ),
						{
							"correlation-id" : message.getHeader( "correlation-id", "" )
						}
					);
				},
				"kid-broadcast" : (message)=>{
					send(
						"fanout/all-kids",
						chooseRandom( kidMessages ),
						{
							"correlation-id" : message.getHeader( "correlation-id", "" )
						}
					);
				},
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
	 * Override to implement your own authentication logic
	 */
	boolean function authenticate( required string login, required string passcode, string host, required channel ) {
		return true;
	}

	/**
	 * Override to implement your own authorization logic
	 */
	boolean function authorize( required string login, required string exchange, required string destination, required string access, required channel ) {
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

	private function chooseRandom( required array list ) {
		return( list[ randRange( 1, arrayLen( list ) ) ] );
	}

}