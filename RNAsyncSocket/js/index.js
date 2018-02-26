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

    this.sockets = NativeModule.NativeSocket;
    this.isConnected = false;
    this.handlers = {};
    this.onAnyHandler = null;

    // Set default handlers
    this.defaultHandlers = {
      connect: () => {
        this.isConnected = true;
      },

      disconnect: () => {
        this.isConnected = false;
      }
    };

    // Set initial configuration
    this.sockets.initialise(host, config);
  }

  _handleEvent(event) {
    if (this.handlers.hasOwnProperty(event.name))
      this.handlers[event.name](
        event.hasOwnProperty("items") ? event.items : null
      );

    if (this.defaultHandlers.hasOwnProperty(event.name))
      this.defaultHandlers[event.name]();

    if (this.onAnyHandler) this.onAnyHandler(event);
  }

  connect() {
    this.sockets.connect();
  }

  on(event, handler) {
    this.handlers[event] = handler;
  }

  onAny(handler) {
    this.onAnyHandler = handler;
  }

  emit(event, data) {
    this.sockets.emit(event, data);
  }

  disconnect() {
    this.sockets.disconnect();
  }
}

export default NativeSocket;
