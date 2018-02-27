import React, { Component } from "react";
import { NativeModules } from "react-native";

class NativeSocket {
  constructor(port, config) {
    if (typeof port === "undefined") {
      throw "Need port for socket";
    }
    if (typeof config === "undefined") {
      config = {};
    }

    this.sockets = NativeModules.NativeSocket;
    this.isConnected = false;

    // Set initial configuration
    this.sockets.initialise(port, config);
  }

  send(msg) {
    if (this.isConnected) {
      this.sockets.send(msg);
    }
  }

  receive(cb) {
    this.sockets.receive(cb);
  }

  connect(success, failure) {
    this.sockets.connect((error, events) => {
      if (error) {
        failure(error);
      }
      this.isConnected = true;
      success(events);
    });
  }

  disconnect() {
    this.sockets.disconnect();
  }
}

export default NativeSocket;
