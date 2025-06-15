// ignore_for_file: public_member_api_docs, sort_constructors_first
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
