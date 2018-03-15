# async-socket-rn

## Example

Not uploaded yet because setting up node_modules has been a hassle.

## Installation

add this in your package.json:

```
"async-socket-rn": "https://github.com/bensonz/async-socket-rn",
```

and add this to your podfile and do `pod install`

```
pod 'async-socket-rn', :path => '../node_modules/async-socket-rn'
```

## Design tradeoffs

The socket automatically ~~transforms all incoming data to base64 encoded data,
that means when you need to use this data, you need to do something like
`window.atob()`~~

This project now is very specific to our cskin project, if you wish to use it
for general purpose, I have tagged a release 0.1 for that.

The socket reads message data and returns a string with header `msg://`; reads
file(image) data, then transforms and saves the file locally at /tmp path and
returns two paths of the file to JS, one for thumbnail and one for original
image, with header `file://`

## Usage

```
import NativeSocket from 'async-socket-rn';

// port and message stopper( when to stop reading)
// below is the default setting
ns = new NativeSocket(2345, '::]]');

ns.listen();
ns.send('Anything');
// important: disconnect removes all handlers
ns.disconnect();

/* Adding handlers, supported ones are
[
  "connected",
  "disconnected",
  "writeData",
  "readDataPartialLength",
  "read"]
*/

ns.on("connected",(type)=>{/* do something */})
ns.on("disconnected",(type)=>{/* do something */})
ns.on("writeData",('ok')=>{/* do something */})
ns.on("readDataPartialLength",(length)=>{/* do something */})
ns.on("read",(data)=>{/* do something */})
```

##### Connected/Disconnected type

Here I wish to talk more about this type in returned data. In event connected,
`type === 'new'` means a new socket connection is successfully established.
Otherwise type is of form "host,port" I am actually not quit sure when the
"host,port" type is send because when I test it it was never sent.

For the event disconnected, `type === 'old'` means an old socket is
disconnected, usually means you manually called disconnect function. Otherwise
the type is an string of error that probably means the socket is closed by the
other end or something else (not you anyway).

| commands              | called when                                                                      |
| --------------------- | -------------------------------------------------------------------------------- |
| connected             | the socket successfully connects                                                 |
| disconnected          | the socket successfully disconnects                                              |
| writeData             | the socket successfully writes data, not called when write data to socket failed |
| readDataPartialLength | did read some data, this calls with the data length as argument                  |
| read                  | when a read is finished, as your given message stopper is seen                   |

## Author

bensonz, mr.bz@hotmail.com

## License

async-socket-rn is available under the MIT license. See the LICENSE file for
more info.
