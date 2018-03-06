import { NativeModules, NativeEventEmitter } from "react-native";

class NativeSocket {
  constructor(port, stopper) {
    if (typeof port === "undefined") {
      throw "Need port for socket";
    }
    if (typeof stopper === "undefined") {
      throw "Need a message stopper for socket";
    }

    this.sockets = NativeModules.NativeSocket;
    this.eventEmitter = new NativeEventEmitter(this.sockets);
    this.subscriptions = [];

    this.isConnected = false;

    // Set initial configuration
    this.sockets.initialise(port, stopper);
  }

  // sends a string message
  send(msg) {
    if (this.isConnected) {
      this.sockets.send(msg);
    }
  }
  connect() {
    this.sockets.connect((err, event) => {
      if (err) {
        console.log("Connection failed", err);
        return;
      }
      console.log("Connection successfull", event);
      this.isConnected = true;
    });
  }
  disconnect() {
    let i;
    for (i = 0; i < this.subscriptions.length; i += 1) {
      this.subscriptions[i].remove();
    }
    this.sockets.disconnect();
  }

  on(event, handler) {
    try {
      this.subscriptions.push(this.eventEmitter.addListener(event, handler));
    } catch (e) {
      console.log(e);
    }
  }
}

export default NativeSocket;
