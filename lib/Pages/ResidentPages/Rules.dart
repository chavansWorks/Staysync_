import 'package:flutter/material.dart';
import 'package:transformable_list_view/transformable_list_view.dart';

class RulesOfSocietyPage extends StatelessWidget {
  final List<String> rules = [
    "Maintain cleanliness in common areas.",
    "No loud music after 10 PM.",
    "Dispose of garbage properly.",
    "No smoking in the hallways.",
    "Pets must be leashed in public areas.",
    "Use gym and pool facilities responsibly.",
    "Visitors must be registered at the gate.",
    "Avoid parking in unauthorized spots.",
    "Report maintenance issues promptly.",
    "Follow the safety guidelines for fire drills.",
    "Pets must be leashed in public areas.",
    "Use gym and pool facilities responsibly.",
    "Visitors must be registered at the gate.",
    "Avoid parking in unauthorized spots.",
    "Report maintenance issues promptly.",
    "Follow the safety guidelines for fire drills."
  ];

  Matrix4 getTransformMatrix(TransformableListItem item) {
    const endScaleBound = 0.9;
    final animationProgress = item.visibleExtent / item.size.height;
    final paintTransform = Matrix4.identity();

    if (item.position != TransformableListItemPosition.middle) {
      final scale = endScaleBound + ((1 - endScaleBound) * animationProgress);
      paintTransform
        ..translate(item.size.width / 2)
        ..scale(scale)
        ..translate(-item.size.width / 2);
    }

    return paintTransform;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 93, 192, 238), Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TransformableListView.builder(
          getTransformMatrix: getTransformMatrix,
          itemBuilder: (context, index) {
            return Container(
              height: 120,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Circular element for each item
                  SizedBox(width: 10),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: index.isEven
                        ? Colors.blueAccent
                        : Colors.lightBlueAccent,
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      rules[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: rules.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add rule action
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
