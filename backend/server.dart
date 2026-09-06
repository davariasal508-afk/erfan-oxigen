import 'dart:convert';
import 'dart:io';

const appName = 'ERFAN OXIGEN';
const appVersion = '2.1.0+102';
const defaultPort = 8787;
const defaultHost = '0.0.0.0';

Directory dataDir = Directory('backend/data');
Directory filesDir = Directory('backend/files');
String apiToken = '';

Future<void> ensureDirs() async {
  if (!dataDir.existsSync()) await dataDir.create(recursive: true);
  if (!filesDir.existsSync()) await filesDir.create(recursive: true);
}

String safeName(String value) => value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');

Future<File> dbFile(String name) async {
  await ensureDirs();
  final safe = safeName(name);
  if (safe.isEmpty) throw ArgumentError('Invalid database name');
  final file = File('${dataDir.path}/$safe.json');
  if (!file.existsSync()) {
    await file.writeAsString('[]');
  }
  return file;
}

Future<dynamic> readJson(String name, {dynamic fallback = const []}) async {
  final file = await dbFile(name);
  try {
    return jsonDecode(await file.readAsString());
  } catch (_) {
    return fallback;
  }
}

Future<void> writeJson(String name, dynamic value) async {
  final file = await dbFile(name);
  final tmp = File('${file.path}.tmp');
  await tmp.writeAsString(const JsonEncoder.withIndent('  ').convert(value));
  if (file.existsSync()) await file.delete();
  await tmp.rename(file.path);
}

void addCors(HttpResponse response) {
  response.headers
    ..set('Access-Control-Allow-Origin', '*')
    ..set('Access-Control-Allow-Headers', 'Content-Type, Authorization')
    ..set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
    ..set('Cache-Control', 'no-store');
}

void jsonResponse(HttpResponse response, int status, dynamic data) {
  addCors(response);
  response.statusCode = status;
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(data));
  response.close();
}

Future<Map<String, dynamic>> readBody(HttpRequest request) async {
  final raw = await utf8.decoder.bind(request).join();
  if (raw.trim().isEmpty) return <String, dynamic>{};
  final decoded = jsonDecode(raw);
  return Map<String, dynamic>.from(decoded as Map);
}

bool authorized(HttpRequest request) {
  if (apiToken.isEmpty) return true;
  final value = request.headers.value('authorization');
  return value == 'Bearer $apiToken';
}

Future<void> handleRequest(HttpRequest request) async {
  try {
    addCors(request.response);
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      return;
    }

    if (!authorized(request)) {
      jsonResponse(request.response, HttpStatus.unauthorized, {'error': 'unauthorized'});
      return;
    }

    final path = request.uri.path;

    if (request.method == 'GET' && path == '/health') {
      jsonResponse(request.response, 200, {
        'ok': true,
        'name': appName,
        'version': appVersion,
        'time': DateTime.now().toIso8601String(),
      });
      return;
    }

    if (request.method == 'GET' && path == '/meta') {
      jsonResponse(request.response, 200, {
        'app': appName,
        'version': appVersion,
        'server': 'dart-local-backend',
        'storage': dataDir.path,
      });
      return;
    }

    if (request.method == 'GET' && path == '/api/snapshot') {
      final snapshot = <String, dynamic>{
        'users': await readJson('users'),
        'exams': await readJson('exams'),
        'chat_messages': await readJson('chat_messages'),
        'chat_threads': await readJson('chat_threads'),
        'ads': await readJson('ads'),
        'admin_profile': await readJson('admin_profile', fallback: <String, dynamic>{}),
        'portfolio': await readJson('portfolio'),
        'courses': await readJson('courses'),
        'certificates': await readJson('certificates'),
        'notifications': await readJson('notifications'),
        'schedule': await readJson('schedule'),
        'customers': await readJson('customers'),
        'view_events': await readJson('view_events'),
      };
      jsonResponse(request.response, 200, snapshot);
      return;
    }

    if (request.method == 'POST' && path == '/api/snapshot') {
      final body = await readBody(request);
      for (final key in [
        'users',
        'exams',
        'chat_messages',
        'chat_threads',
        'ads',
        'admin_profile',
        'portfolio',
        'courses',
        'certificates',
        'notifications',
        'schedule',
        'customers',
        'view_events',
      ]) {
        if (body.containsKey(key)) await writeJson(key, body[key]);
      }
      jsonResponse(request.response, 200, {'ok': true, 'savedAt': DateTime.now().toIso8601String()});
      return;
    }

    if (path.startsWith('/api/data/')) {
      final name = safeName(path.substring('/api/data/'.length));
      if (name.isEmpty) {
        jsonResponse(request.response, 400, {'error': 'invalid_name'});
        return;
      }
      if (request.method == 'GET') {
        jsonResponse(request.response, 200, {'data': await readJson(name)});
        return;
      }
      if (request.method == 'POST') {
        final body = await readBody(request);
        await writeJson(name, body);
        jsonResponse(request.response, 200, {'ok': true});
        return;
      }
    }

    if (request.method == 'GET' && path == '/api/export') {
      final snapshot = <String, dynamic>{
        'exportedAt': DateTime.now().toIso8601String(),
        'snapshot': await readJson('snapshot_cache', fallback: const <String, dynamic>{}),
      };
      jsonResponse(request.response, 200, snapshot);
      return;
    }

    jsonResponse(request.response, 404, {'error': 'not_found', 'path': path});
  } catch (e, st) {
    stderr.writeln(e);
    stderr.writeln(st);
    jsonResponse(request.response, 500, {'error': e.toString()});
  }
}

void printUsage() {
  stdout.writeln('ERFAN OXIGEN backend $appVersion');
  stdout.writeln('Usage: dart run backend/server.dart [--host=0.0.0.0] [--port=8787] [--data-dir=backend/data] [--files-dir=backend/files] [--token=SECRET]');
}

Future<void> main(List<String> args) async {
  var host = Platform.environment['OXIGEN_HOST'] ?? defaultHost;
  var port = int.tryParse(Platform.environment['OXIGEN_PORT'] ?? '') ?? defaultPort;
  final dataOverride = Platform.environment['OXIGEN_DATA_DIR'];
  final filesOverride = Platform.environment['OXIGEN_FILES_DIR'];
  apiToken = Platform.environment['OXIGEN_API_TOKEN'] ?? '';

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      printUsage();
      return;
    }
    if (arg.startsWith('--host=')) host = arg.substring('--host='.length);
    if (arg.startsWith('--port=')) port = int.tryParse(arg.substring('--port='.length)) ?? port;
    if (arg.startsWith('--data-dir=')) dataDir = Directory(arg.substring('--data-dir='.length));
    if (arg.startsWith('--files-dir=')) filesDir = Directory(arg.substring('--files-dir='.length));
    if (arg.startsWith('--token=')) apiToken = arg.substring('--token='.length);
  }

  if (dataOverride != null && dataOverride.trim().isNotEmpty) dataDir = Directory(dataOverride);
  if (filesOverride != null && filesOverride.trim().isNotEmpty) filesDir = Directory(filesOverride);

  await ensureDirs();
  final server = await HttpServer.bind(host, port);
  stdout.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  stdout.writeln('$appName backend $appVersion');
  stdout.writeln('Listening: http://$host:$port');
  stdout.writeln('Data: ${dataDir.absolute.path}');
  stdout.writeln('Files: ${filesDir.absolute.path}');
  stdout.writeln('Auth: ${apiToken.isEmpty ? 'OFF (LAN/dev mode)' : 'ON'}');
  stdout.writeln('Health: http://127.0.0.1:$port/health');
  stdout.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  await for (final request in server) {
    await handleRequest(request);
  }
}
