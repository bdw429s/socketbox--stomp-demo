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
			This is a simple chat application that uses WebSockets to communicate with the server. It is built using CFML (running on BoxLang) and our new
			<a href="https://forgebox.io/view/socketbox">SocketBox library</a>.  SocketBox is a new feature built into CommandBox and the BoxLang MiniServer
			to be able to easily create WebSocket servers in CFML that work for Adobe ColdFusion, Lucee Server, or BoxLang!
		</p>

		<label for="serverTimeSubscriptionBox">Current Server Time <input type="checkbox" id="serverTimeSubscriptionBox" name="serverTimeSubscriptionBox" checked="checked" onclick="toggleTime(this.checked);"></label>
		<span id="server-time"></span><br>
		<br>
		<label for="serverTimeSubscriptionBox">Lucky Numbers <input type="checkbox" id="luckyNumberSubscriptionBox" name="luckyNumberSubscriptionBox" checked="checked" onclick="toggleNums(this.checked);"></label>
		<div id="lucky-numbers" class="lucky-numbers"></div>
		
		<br>
		<br>
		<button onClick="client.publish({ destination: 'lucky-numbers', body: '42' });">send</button>
		</main>
		<cfscript>		
			request.connectionAddress = '://#cgi.server_name#'
			if( cgi.https == true || cgi.https == 'on' ) {
				request.connectionAddress = 'wss' & request.connectionAddress;
			} else if( (getHTTPRequestData().headers['x-forwarded-proto'] ?: '') == 'https' ) {
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
			onConnect: () => {
				toggleTime(true);
				toggleNums(true);
			},
			onStompError: error => {
				console.log("STOMP error: " + error.headers.message);
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
				if (enable && !window.serverTimeSubscription) {
					window.serverTimeSubscription = client.subscribe('server-time', function( message ) {
						document.getElementById('server-time').innerText = message.body;
					});
				} else {
					window.serverTimeSubscription.unsubscribe();
					window.serverTimeSubscription = null;
				}
			}

			function toggleNums(enable) {
				if (enable && !window.luckyNumberSubscription) {
					window.luckyNumberSubscription = client.subscribe('lucky-numbers', message => {
						const luckyNumbers = document.getElementById('lucky-numbers');
						luckyNumbers.innerHTML += message.body + '<br>';
						luckyNumbers.scrollTop = luckyNumbers.scrollHeight;
					});
				} else {
					window.luckyNumberSubscription.unsubscribe();
					window.luckyNumberSubscription = null;
				}
			}
		</script>
	</body>
</cfoutput>
</html>
