import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyWidget extends StatelessWidget {
  final String itemName;
  const EmptyWidget({super.key,required this.itemName});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Lottie.asset("assets/not-found.json",width: 200)),
          Text("No ${itemName}s found.",style: TextStyle(
            fontSize: 16,
            color: Colors.redAccent.withOpacity(0.7)
          ),)
        ],
      ),
    );
  }
}
