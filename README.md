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

## Usage

```
import NativeSocket from 'async-socket-rn';

// port and message stopper( when to stop reading)
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
