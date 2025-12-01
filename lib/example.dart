import 'package:gemini_agent_tools/tool_annotation.dart';

part 'example.tools.g.dart';

@Tool(
  name: "save",
  description: """
  (internal) This function saves to your agent memory...
  """,
  requiredFields: ["agentNotes"],
)
class SaveTool {
  final String agentNotes;

  SaveTool({required this.agentNotes});
}
