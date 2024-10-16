<!DOCTYPE html>
<html lang="en-US">
<head>
	<title>STOMP SocketBox Demo</title>
	<link
				rel="stylesheet"
				href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css"
	>
	<link rel="stylesheet" href="/resources/styles.css">
	<!--
		JSPM Generator Import Map
		Edit URL: https://generator.jspm.io/#U2NgYGBkDM0rySzJSU1hcCguyc8t0AeTWcUO5noGega6SakliaYAYTzJAykA
	-->
	<script type="importmap">
	  {
		"imports": {
		  "@stomp/stompjs": "https://ga.jspm.io/npm:@stomp/stompjs@7.0.0/esm6/index.js"
		}
	  }
	</script>
	
	<!-- ES Module Shims: Import maps polyfill for modules browsers without import maps support (all except Chrome 89+) -->
	<script async src="https://ga.jspm.io/npm:es-module-shims@1.5.1/dist/es-module-shims.js" crossorigin="anonymous"></script>
</head>
<body>
<cfoutput>
	<body>
		<main class="container">
		<h1>STOMP SocketBox Demo</h1>
		<p>
			This is a demo that uses WebSockets to communicate with the server. It is built using CFML (running on BoxLang) and our new
			<a href="https://forgebox.io/view/socketbox">SocketBox library</a>.  SocketBox is a new feature built into CommandBox and the BoxLang MiniServer
			to be able to easily create WebSocket servers in CFML that work for Adobe ColdFusion, Lucee Server, or BoxLang!
		</p>
		<p>
			This demo uses the STOMP broker functionality, which sits on top of the simple websocket functionality and adds topic and routing semanatics.  You can 
			use any Stomp.js client library and create a STOMP connection, over which you can subscribe to topics, and send messages to different desitinations.  We are 
			using direct routing, topic routing, fanout routing, and distribution routing as well as server-side listeners.  
		</p>
		<p>
			All streaming data below is generated randomly by a daemon thread on the server to mimic real-time information which broadcasts out messages regardless of whether or not there is a browser with a WebSocket 
			connected. If you open two tabs, you'll see they are reveiving the same data.  Open your browser's console to see debug info from the Stomp.js library.  As you subscribe and 
			unsubscribe from different topics, you'll see the incoming messages change based on your subscriptions, which are authorized and tracked on the server.
		</p>
		<p>
			Full source code for this demo available here: <a href="https://github.com/bdw429s/socketbox-stomp-demo">bdw429s/socketbox-stomp-demo</a>.  You can run this 
			yourself on the latest BoxLang MiniServer or on CommandBox 6.1+ and any CF engine.
		</p>		
		<hr>

		<div id="lucky-numbers-wrapper" >
			<em>When subscribed to this topic, you receive the current server time every second.</em><br><br>
			<label for="serverTimeSubscriptionBox">Current Server Time <input type="checkbox" id="serverTimeSubscriptionBox" name="serverTimeSubscriptionBox" checked="checked" onclick="toggleTime(this.checked);"></label>
			<span id="server-time"></span>
			<br>
			<br>
			<br>
			<em>Subscribe to this topic to receive a stream of lucky numbers.</em><br><br>
			<label for="luckyNumberSubscriptionBox">Lucky Numbers <input type="checkbox" id="luckyNumberSubscriptionBox" name="luckyNumberSubscriptionBox" checked="checked" onclick="toggleNums(this.checked);"></label>
			<div id="lucky-numbers" class="scroller"></div>
		</div>
		<div id="food-wrapper" >
			<em>Here you have the choice of 3 topics containing different types of food.  These use a topic exchange with wildcard for matching.</em><br><br>
			<label for="foodSubscriptionBoxAll">All Food <input type="radio" id="foodSubscriptionBoxAll" name="foodSubscriptionBox" checked="checked" onclick="toggleFood('All');"></label>
			<label for="foodSubscriptionBoxFruit">Fruit Only <input type="radio" id="foodSubscriptionBoxFruit" name="foodSubscriptionBox" onclick="toggleFood('Fruit');"></label>
			<label for="foodSubscriptionBoxSnacks">Snacks Only <input type="radio" id="foodSubscriptionBoxSnacks" name="foodSubscriptionBox" onclick="toggleFood('Snacks');"></label>
			<label for="foodSubscriptionBoxNone">None <input type="radio" id="foodSubscriptionBoxNone" name="foodSubscriptionBox" onclick="toggleFood('None');"></label>
			<div id="food" class="scroller"></div>
		</div>
		<div style="clear: both;">
			<br>
			<br>
			<hr>
			<br>    
			<div class="center-container">
				<em>This button sends a message to the server, which replies over a private channel that only your STOMP session can see, creating an RPC-style callback
					for low-latency round trip server hits that don't require an Ajax call.</em>
			</div>
			<br>
			<div class="center-container">
				<button onClick="sendPing();">Ping</button>
			</div>
			<div class="center-container">
				<div id="ping-response"></div>
			</div>
		</div>
		<hr>
		<div class="center-container">
			<h2>Family Messenger</h2>
		</div>
		<br>
		<div class="center-container">
			<em>Utilizing a series of fanout exchanges, we can broadcast messages to different groups of family members.  All members in the group receive the message.
			The "assign a chore" button uses a distribution group, evenly distributing chores to a single family member at a time.</em>
		</div>
		<br>
		<div class="center-container">
			<button onclick="sendFamilyMessage();">Message entire family</button>&nbsp;&nbsp;&nbsp;
			<button onclick="sendParentMessage();">Message parents</button>&nbsp;&nbsp;&nbsp;
			<button onclick="sendKidMessage();">Message kids</button>&nbsp;&nbsp;&nbsp;
			<button onclick="assignChore();">Assign a chore</button>
		</div>
		<br> 
		<div class="scrolling-container">
			<div style="width: 75%; text-align:center;">
				<h3>Mom</h3>
				<div style="width: 100%; text-align:left;" class="scroller" id="mom-scroller"></div>
			</div>
			<div style="width: 75%; text-align:center;">
				<h3>Dad</h3>
				<div style="width: 100%; text-align:left;" class="scroller" id="dad-scroller"></div>
			</div>
			<div style="width: 75%; text-align:center;">
				<h3>Susie</h3>
				<div style="width: 100%; text-align:left;" class="scroller" id="susie-scroller"></div>
			</div>
			<div style="width: 75%; text-align:center;">
				<h3>Timmy</h3>
				<div style="width: 100%; text-align:left;" class="scroller" id="timmy-scroller"></div>
			</div>
		</div>
		</main>
		<cfscript>		
			request.connectionAddress = '://#cgi.server_name#'
			headers = getHTTPRequestData().headers;
			if( cgi.https == true || cgi.https == 'on' ) {
				request.connectionAddress = 'wss' & request.connectionAddress;
			} else if( (headers['x-forwarded-proto'] ?: '') == 'https' ) {
				request.connectionAddress = 'wss' & request.connectionAddress;
			} else {
				request.connectionAddress = 'ws' & request.connectionAddress & ":" & cgi.SERVER_PORT;
			}
			request.connectionAddress = request.connectionAddress & '/ws';
		</cfscript>
		<script type="module">
		import { Client } from '@stomp/stompjs';
	
		const url = '#request.connectionAddress#';
	
		// Create a new STOMP client
		window.client = new Client({
			brokerURL: url,
			reconnectDelay: 5000,  // Optional: reconnect after 5 seconds
			heartbeatIncoming: 10000,
			heartbeatOutgoing: 10000,
			connectHeaders: {
			login: 'myuser',
			passcode: 'mypass'
			},
			onConnect: (frame) => {
				window.sessionID = frame.headers.session;
				toggleTime( document.getElementById('serverTimeSubscriptionBox').checked );
				toggleNums( document.getElementById('luckyNumberSubscriptionBox').checked );
				var foodType = 'All';
				if( document.getElementById('foodSubscriptionBoxFruit').checked ) {
					foodType = 'Fruit';
				} else if( document.getElementById('foodSubscriptionBoxSnacks').checked ) {
					foodType = 'Snacks';
				} else if( document.getElementById('foodSubscriptionBoxNone').checked ) {
					foodType = 'None';
				}
				toggleFood( foodType );
				pingListen();
				familyListen();
			},
			onStompError: error => {
				console.log("STOMP error: " + error.headers.message);
			},
			onWebSocketClose: () => {
				console.log("WebSocket connection closed");
				window.serverTimeSubscription = null;
				window.luckyNumberSubscription = null;
				window.foodAllSubscription = null;
				window.foodFruitSubscription = null;
				window.foodSnacksSubscription = null;
				window.pongListener = null;
				window.momListener = null;
				window.dadListener = null;
				window.susieListener = null;
				window.timmyListener = null;
			},
			debug: function (str) {
				console.log(str);
			},
		});
	
		// Activate the client
		client.activate();
		</script>
		
		<script>
			function toggleTime(enable) {
				if (enable) {
					if( !window.serverTimeSubscription ) {
						window.serverTimeSubscription = client.subscribe('server-time', function( message ) {
							document.getElementById('server-time').innerText = message.body;
						});
					}
				} else if( window.serverTimeSubscription ) {
					window.serverTimeSubscription.unsubscribe();
					window.serverTimeSubscription = null;
				}
			}

			function toggleNums(enable) {
				if (enable) {
					if(!window.luckyNumberSubscription) {
						window.luckyNumberSubscription = client.subscribe('lucky-numbers', message => {
							const luckyNumbers = document.getElementById('lucky-numbers');
							luckyNumbers.innerHTML += message.body + '<br>';
							const lines = luckyNumbers.innerHTML.split('<br>');
							
							// Trim to the last 100 lines
							if (lines.length > 100) {
								luckyNumbers.innerHTML = lines.slice(-100).join('<br>');
							}
							
							luckyNumbers.scrollTop = luckyNumbers.scrollHeight;
						});
					}
				} else if( window.luckyNumberSubscription ) {
					window.luckyNumberSubscription.unsubscribe();
					window.luckyNumberSubscription = null;
				}
			}

			function toggleFood(type) {
				if (type != 'All' && window.foodAllSubscription) {
					window.foodAllSubscription.unsubscribe();
					window.foodAllSubscription = null;
				}
				if (type != 'Fruit' && window.foodFruitSubscription) {
					window.foodFruitSubscription.unsubscribe();
					window.foodFruitSubscription = null;
				}
				if (type != 'Snacks' && window.foodSnacksSubscription) {
					window.foodSnacksSubscription.unsubscribe();
					window.foodSnacksSubscription = null;
				}
				if (type == 'All' && !window.foodAllSubscription) {
					window.foodAllSubscription = client.subscribe('all-food', updateFood );
				} else if (type == 'Fruit' && !window.foodFruitSubscription) {
					window.foodFruitSubscription = client.subscribe('only-fruit', updateFood);
				} else if (type == 'Snacks' && !window.foodSnacksSubscription) {
					window.foodSnacksSubscription = client.subscribe('only-snacks', updateFood );
				}
			}

			function updateFood(message) {
				const food = document.getElementById('food');
				var foodData = JSON.parse(message.body);
				food.innerHTML += '<span style="color:' + ( foodData.type == 'fruit' ? 'blue' : 'red' ) + '">' + foodData.food + '</span><br>';

				const lines = food.innerHTML.split('<br>');
				
				// Trim to the last 100 lines
				if (lines.length > 100) {
					food.innerHTML = lines.slice(-100).join('<br>');
				}

				food.scrollTop = food.scrollHeight;
			}

			function pingListen() {
				if( !window.pongListener ) {
					window.pongListener = client.subscribe('pong.' + window.sessionID, message => {
						console.log("Received pong sdfsdf: " + message.body);
						document.getElementById('ping-response').innerHTML = '<strong>' + message.body + '</strong>';
					});
				}
			}

			function sendPing() {
				client.publish({
					destination: 'ping',
					body: 'Ping!',
					headers: {
						"reply-to" : 'pong.' + window.sessionID
					}
				});
			}

			function familyListen() {
				if( !window.momListener ) {
					window.momListener = client.subscribe('mom', message => {
						if( message.headers['correlation-id'] != window.sessionID ) {
							return;
						}
						const scroller = document.getElementById('mom-scroller');
						scroller.innerHTML += message.body + '<br>';
						scroller.scrollTop = scroller.scrollHeight;
					});
				}
				if( !window.dadListener ) {
					window.dadListener = client.subscribe('dad', message => {
						if( message.headers['correlation-id'] != window.sessionID ) {
							return;
						}
						const scroller = document.getElementById('dad-scroller');
						scroller.innerHTML += message.body + '<br>';
						scroller.scrollTop = scroller.scrollHeight;
					});
				}
				if( !window.susieListener ) {
					window.susieListener = client.subscribe('susie', message => {
						if( message.headers['correlation-id'] != window.sessionID ) {
							return;
						}
						const scroller = document.getElementById('susie-scroller');
						scroller.innerHTML += message.body + '<br>';
						scroller.scrollTop = scroller.scrollHeight;
					});
				}
				if( !window.timmyListener ) {
					window.timmyListener = client.subscribe('timmy', message => {
						if( message.headers['correlation-id'] != window.sessionID ) {
							return;
						}
						const scroller = document.getElementById('timmy-scroller');
						scroller.innerHTML += message.body + '<br>';
						scroller.scrollTop = scroller.scrollHeight;
					});
				}
			}

			

			function sendFamilyMessage() {
				client.publish({
					destination: 'family-broadcast',
					body: '',
					headers: {
						"correlation-id" : window.sessionID
					}
				});
			}

			function sendParentMessage() {
				client.publish({
					destination: 'parent-broadcast',
					body: '',
					headers: {
						"correlation-id" : window.sessionID
					}
				});
			}

			function sendKidMessage() {
				client.publish({
					destination: 'kid-broadcast',
					body: '',
					headers: {
						"correlation-id" : window.sessionID
					}
				});
			}

			function assignChore() {
				client.publish({
					destination: 'family-chores',
					body: '',
					headers: {
						"correlation-id" : window.sessionID
					}
				});
			}
		</script>
	</body>
</cfoutput>
</html>
