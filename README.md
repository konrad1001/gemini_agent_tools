# gemini_agent_tools

`gemini_agent_tools` is a Dart/Flutter package that enables **automatic code generation** for Gemini-style agent tool declarations to be used in with the [REST api](https://ai.google.dev/api).
It allows you to define tools as **annotated Dart classes**, and a custom `build_runner` generator produces the correct API-ready JSON schemas automatically.

This eliminates manual boilerplate, keeps tool definitions type-safe, and ensures your agent functions remain in sync with your code.

---

## 🚀 Features

- 🔧 **Annotate classes to define agent tools**
- ⚙️ **Build-runner code generator** creates `*.tools.g.dart` output
- 📐 Auto-generates:
  - tool names
  - descriptions
  - JSON schema parameters
  - property ordering
  - required fields

- 🐍 Converts camelCase → snake_case automatically

---

## 📥 Installation

Add the package:

```sh
dart pub add gemini_agent_tools
```

And the dev dependency for `build_runner`:

```sh
dart pub add --dev build_runner
```

---

## 🧩 Usage

### 1. **Annotate a class with `@Tool`**

```dart
import 'package:gemini_agent_tools/tool_annotation.dart';

@Tool(
  name: "save",
  description: "Stores information to agent memory",
  requiredFields: ["agentNotes"],
)
class SaveTool {
  final String agentNotes;

  SaveTool(this.agentNotes);
}
```

The annotation fields:

| Field                           | Type           | Description                  |
| ------------------------------- | -------------- | ---------------------------- |
| **name**                        | `String`       | The tool's function name     |
| **description**                 | `String`       | Human-readable description   |
| **requiredFields** _(optional)_ | `List<String>` | Marks parameters as required |

Parameters are generated from class fields automatically.

---

### 2. **Run the generator**

```
dart run build_runner build
```

This will produce a file:

```
save_tool.tools.g.dart
```

---

### 3. **Generated Output Example**

```dart
const Map saveToolAsMap = {
  "name": "save",
  "description": "Stores information to agent memory",
  "parameters": {
    "type": "object",
    "properties": {
      "agent_notes": {"type": "string"}
    },
    "propertyOrdering": ["agent_notes"],
    "required": ["agent_notes"]
  }
};
```

This object is ready to pass directly into a Gemini REST API `functionDeclarations` list.
