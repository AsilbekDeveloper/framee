import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/components/shared_widgets.dart';
import 'package:framee/features/home/presentation/widgets/loading_feed.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders three shimmer placeholders', (tester) async {
    await pumpApp(tester, const LoadingFeed(), settle: false);

    expect(find.byType(PostCardShimmer), findsNWidgets(3));
  });
}
