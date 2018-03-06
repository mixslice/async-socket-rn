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

The socket automatically transforms all incoming data to base64 encoded data,
that means when you need to use this data, you need to do something like

```
window.atob(data)
```

I use the package base-64 (avaliable in npm) to decode and encode data. This is
useful when you have file data come in. A better solution that added modularity
to the project is adding base64 encoding/decoding, and write a special case for
`.on("read", (data)=>{})`. But because I don't know whether a file is sent or
pure string, I am not exactly sure of how to deal with the data.

An example is: if I have an image send, base64.decode(imageData) transforms data
into whitespaces. Then I won't be able to know what this is in javascript. In
fact right now I do it as such:

```
const meta = msg.slice(0, 20);
if (meta.includes('file://')) {
      const idata = 'data:image/jpeg;base64,' + base64.encode(msg.substr(20));
      // build image with idata
}
```

Then you can use imagesStr to build an image. In React Native this is done as:

```
<Image source={{
  uri: idata,
}}/>)
```

## Usage

```
import NativeSocket from 'async-socket-rn';

// port and message stopper( when to stop reading)
// below is the default setting
ns = new NativeSocket(2345, '::]]');

ns.connect();
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

ns.on("connected",(data)=>{/* do something */})
```

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
