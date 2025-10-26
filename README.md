# 🛠 mg_tools
[![Pub Version](https://img.shields.io/pub/v/mg_tools.svg)](https://pub.dev/packages/mg_tools)
![Null Safety](https://img.shields.io/badge/null_safety-%E2%9C%85-green)
[![GitHub Stars](https://img.shields.io/github/stars/mohamadalghanem474/mg_tools?style=social)](https://github.com/mohamadalghanem474/mg_tools)

---
CLI tool to generate Dart models from `.dto.json` files using `freezed` and `json_serializable`.

---

## 🚀 Features

- 🔍 Auto-scan project for all `.dto.json` files
- 📄 Supports targeting a single file
- 🔄 Smart overwrite control using `--replace`
- 🧩 Supports nested objects and nested lists
- 📆 Auto-detect `DateTime` fields
- 🔑 Annotates with `@JsonKey(name: "...", includeIfNull: false)`
- 📃 Output all models in the same `.dart` file
- 📚 Generates helper methods:
  - `MyModel myModelFromJson(String str)`
  - `String myModelToJson(MyModel data)`
  - or for list responses:
    - `List<MyModel> myModelListFromJson(String str)`
    - `String myModelListToJson(List<MyModel> data)`
- 🐣 Clean, minimal, and fully ready for `freezed` & `json_serializable`

---

## 🧰 Getting started
- Make sure you have the following dev dependencies in your `pubspec.yaml`:
```yaml
dependencies:
  freezed_annotation: ^3.0.0
  json_annotation: ^4.9.0
```
```yaml
dev_dependencies:
  mg_tools: ^1.0.3
  build_runner: ^2.4.15
  freezed: ^3.0.6
  json_serializable: ^6.9.5
```

Then run:

```bash
dart pub get
```
---

## ⚙️ Usage

### ✅ Generate models from all `.dto.json` files:
```bash
dart run mg_tools
```

### 🔁 Force replace existing generated files:
```bash
dart run mg_tools --replace
```

### 🎯 Generate model from a single file:
```bash
dart run mg_tools user.dto.json
```

### 🎯 + 🔁 Replace single file if it exists:
```bash
dart run mg_tools user.dto.json --replace
```

---

## 📁 Example

Given a file named `user.dto.json`:

```json
{
  "id": 1,
  "name": "John",
  "email": "john@example.com",
  "createdAt": "2024-03-20T12:00:00Z",
  "profile": {
    "avatar": "link"
  },
  "tags": ["dev", "dart"]
}
```

It generates a `user.dart` file like:

```dart
@freezed
class User with _$User {
  const factory User({
    @JsonKey(name: "id", includeIfNull: false) int? id,
    @JsonKey(name: "name", includeIfNull: false) String? name,
    @JsonKey(name: "email", includeIfNull: false) String? email,
    @JsonKey(name: "createdAt", includeIfNull: false) DateTime? createdAt,
    @JsonKey(name: "profile", includeIfNull: false) UserProfile? profile,
    @JsonKey(name: "tags", includeIfNull: false) List<String>? tags,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

---

## 💡 Tips

## 📣 Contribute

Feel free to open an issue or submit a PR with improvements, features, or bug fixes 🚀

---

## 📄 License

MIT
