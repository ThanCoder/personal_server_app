import 'dart:io';

typedef OnReqCallback = void Function(HttpRequest req);
typedef OnSocketCallback = void Function(HttpRequest req, WebSocket socket);

class TServer {
  static final TServer instance = TServer._();
  TServer._();
  factory TServer() => instance;

  int _port = 8080;
  // listener
  final Map<String, Map<String, OnReqCallback>> _routes = {
    'GET': {},
    'POST': {},
    'PUT': {},
    'DELETE': {},
  };
  final List<OnSocketCallback> _onSocketListener = [];

  HttpServer? _server;
  Future<void> startListen({
    String address = '0.0.0.0',
    int port = 8080,
  }) async {
    // if (_server == null) return;
    _port = port;
    _server = await HttpServer.bind(address, _port, shared: true);

    await for (var req in _server!) {
      final urlPath = req.uri.path;
      final method = req.method;

      // :id -> params
      // print(req.uri.pathSegments);
      if (WebSocketTransformer.isUpgradeRequest(req)) {
        // is websocket
        final socket = await WebSocketTransformer.upgrade(req);
        for (var eve in _onSocketListener) {
          eve.call(req, socket);
        }
        continue;
      }

      // for http
      final route = _routes[method]![urlPath];

      if (route != null) {
        route(req);
      } else {
        req.response
          ..statusCode = HttpStatus.notFound
          ..write('404 Not Found')
          ..close();
      }
    }
  }

  // socket
  void onSocketListen(OnSocketCallback onWebSocket) {
    _onSocketListener.add(onWebSocket);
  }

  void get(String path, OnReqCallback onRequest) {
    _routes['GET']![path] = onRequest;
  }

  void post(String path, OnReqCallback onRequest) {
    _routes['POST']![path] = onRequest;
  }

  void put(String path, OnReqCallback onRequest) {
    _routes['PUT']![path] = onRequest;
  }

  void delete(String path, OnReqCallback onRequest) {
    _routes['DELETE']![path] = onRequest;
  }

  Future<void> stop({bool force = false}) async {
    await _server?.close(force: force);
    _routes['GET']!.clear();
    _routes['POST']!.clear();
    _routes['PUT']!.clear();
    _routes['DELETE']!.clear();
    _onSocketListener.clear();
  }

  int get getPort => _port;
}
