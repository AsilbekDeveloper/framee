import 'package:flutter/material.dart';

import '../../../../../core/components/shared_widgets.dart';

class LoadingFeed extends StatelessWidget {
  const LoadingFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (_, _) => const PostCardShimmer(),
    );
  }
}
