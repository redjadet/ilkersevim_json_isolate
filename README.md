# ilkersevim_json_isolate

JSON map/list decode and encode helpers that offload large payloads with
Flutter `compute`.

## Why use this package?

- Keep large JSON encoding and decoding work off Flutter's UI isolate.
- Avoid isolate startup cost for small payloads through built-in thresholds.
- Decode strings or UTF-8 bytes directly into validated map/list result types.

License: [Apache-2.0](LICENSE). Issues:
[github.com/redjadet/ilkersevim_json_isolate/issues](https://github.com/redjadet/ilkersevim_json_isolate/issues).

## Installation

```yaml
dependencies:
  ilkersevim_json_isolate: ^0.1.2
```

Requires Flutter `>=3.38.0`, Dart `>=3.12.0`. Hosted dependency only (no
`path:` / `git:`).

## Usage

```dart
import 'package:ilkersevim_json_isolate/ilkersevim_json_isolate.dart';

final map = await decodeJsonMap('{"ok": true}');
final list = await decodeJsonList('[1, 2, 3]');
final encoded = await encodeJsonIsolate({'a': 1});
```

Decode paths under 8 KiB (and small collections for encode) stay on the
current isolate; larger payloads use `compute`.

## API stability

Public function names, return types, thresholds, and `FormatException`
behavior are a semantic-versioned contract. Breaking changes require a major
version bump.

## Publishing

Releases are tagged `vX.Y.Z` matching `pubspec.yaml`. Automated publishing uses
GitHub Actions OIDC with the protected `pub.dev` Environment (reviewer:
`redjadet`).
