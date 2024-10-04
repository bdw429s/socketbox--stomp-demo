component extends="modules.socketbox.models.WebSocketSTOMP" {
	variables.debugMode = true;
	

	/**
	 * Override to implement your own authentication logic
	 */
	function authenticate( required string login, required string passcode, string host ) {
		return true;
	}

	/**
	 * Override to implement your own authorization logic
	 */
	function authorize( required string login, required string exchange, required string destination, required string access ) {
		return true;
	}

}