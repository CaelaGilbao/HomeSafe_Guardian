import 'dart:convert';
import 'dart:io';

void main() {
  // Define the port on which the mock RTSP server will listen
  final int port = 554;

  // Start the mock RTSP server
  HttpServer.bind(InternetAddress.anyIPv4, port).then((server) {
    print('Mock RTSP server listening on port $port');

    // Handle incoming requests
    server.listen((HttpRequest request) {
      // Extract the request method and path
      final String method = request.method;
      final String path = request.uri.path;

      // Log the request
      print('Received $method request for $path');

      // Handle different request paths
      switch (path) {
        case '/describe':
          _handleDescribeRequest(request);
          break;
        case '/setup':
          _handleSetupRequest(request);
          break;
        // Add more cases to handle other RTSP methods (PLAY, TEARDOWN, etc.)
        default:
          _sendNotFoundResponse(request);
          break;
      }
    });
  }).catchError((error) {
    print('Error starting mock RTSP server: $error');
  });
}

// Function to handle DESCRIBE requests
void _handleDescribeRequest(HttpRequest request) {
  // Mock response payload for DESCRIBE request
  final Map<String, dynamic> responseJson = {
    'cameraId': 'mock_camera_123',
    'cameraName': 'Mock Camera',
    'streamUrl': 'rtsp://example.com/stream',
    // Add more metadata or stream information as needed
  };

  // Send the response
  _sendJsonResponse(request, responseJson);
}

// Function to handle SETUP requests
void _handleSetupRequest(HttpRequest request) {
  // Mock response for SETUP request
  final String response = '200 OK\r\nSession: mock_session_456\r\n';

  // Send the response
  _sendTextResponse(request, response);
}

// Function to send JSON response
void _sendJsonResponse(HttpRequest request, Map<String, dynamic> responseJson) {
  final String responseBody = json.encode(responseJson);

  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.json
    ..write(responseBody)
    ..close();
}

// Function to send plain text response
void _sendTextResponse(HttpRequest request, String responseText) {
  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.text
    ..write(responseText)
    ..close();
}

// Function to send 404 Not Found response
void _sendNotFoundResponse(HttpRequest request) {
  request.response
    ..statusCode = HttpStatus.notFound
    ..write('Not Found')
    ..close();
}
