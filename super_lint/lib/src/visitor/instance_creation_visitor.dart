import '../index.dart';

class InstanceCreationCollector extends RecursiveAstVisitor<void> {
  void Function(InstanceCreationExpression node) onVisitInstanceCreationExpression;
  InstanceCreationCollector({
    required this.onVisitInstanceCreationExpression,
  });

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    onVisitInstanceCreationExpression(node);
    super.visitInstanceCreationExpression(node);
  }
}
