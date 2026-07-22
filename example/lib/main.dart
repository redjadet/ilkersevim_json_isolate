import 'package:flutter/widgets.dart';
import 'package:ilkersevim_json_isolate/ilkersevim_json_isolate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Map<String, dynamic> map = await decodeJsonMap('{"hello":"world"}');
  final String encoded = await encodeJsonIsolate(map);
  // ignore: avoid_print
  print(encoded);
}
