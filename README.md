# 🛠 mg_tools

CLI tool to generate Dart models from `.dto.json` files using `freezed` and `json_serializable`.

---

## 🚀 Features

- 🔍 Auto-scan project for all `.dto.json` files
- 📄 Supports targeting a single file
- 🔄 Smart overwrite control using `--replace`
- 🧩 Supports nested objects and nested lists
- 📆 Auto-detect `DateTime` fields
- 🔑 Annotates with `@JsonKey(name: "...", includeIfNull: false)`
- 📃 Output all models in the same `.dto.dart` file
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
dev_dependencies:
  mg_tools: latest
  build_runner: any
  freezed: any
  json_serializable: any
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
dart run mg_tools path/to/user.dto.json
```

### 🎯 + 🔁 Replace single file if it exists:
```bash
dart run mg_tools path/to/user.dto.json --replace
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

It generates a `user.dto.dart` file like:

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

- After generating your models, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---


## 📣 Contribute

Feel free to open an issue or submit a PR with improvements, features, or bug fixes 🚀

---

## 📄 License

MIT
