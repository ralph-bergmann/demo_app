# Demo Project

to run the project:

```bash
flutter run --release
```

To (re)build the generated code:

```bash
dart run build_runner build
```

## Technical Notes

### ChangeNotifier vs. Bloc

My initial implementation used `ChangeNotifier`, as I usually do. You can see
it in the `home_page_controller.dart` file.

I then switched to `Bloc`, as requestd. You can see it in the
`home_page_bloc.dart` file.

I'm not sure if I did it right, it is the first time I use Bloc. I used the
[GitHub Search example](https://bloclibrary.dev/tutorials/github-search/) for inspiration.

Actually, I was surprised how much more code/classes I had to write to use Bloc. But it works.


### Performance Optimization

Currently, the JSON is parsed on the main thread. I think that's fine for now,
because the JSON data is small, but it's not ideal. Larger JSONs should be
parsed using
a [compute function](https://api.flutter.dev/flutter/foundation/compute.html) or
even better in a
dedicated [Isolate](https://api.flutter.dev/flutter/dart-isolate/Isolate-class.html).
See
also [When to Use Dart Isolates: Limitations and Practical Examples](https://blog.flutter.wtf/when-to-use-dart-isolates/)

### UI improvements

I did not implement ListView animations. Both datasets are almost the
same, so there are no animations to see. For a more complex dataset, animations
would be a nice addition. In this case, I would probably
use [diffutil_dart](https://pub.dev/packages/diffutil_dart) to calculate the
changes between the old and new data and then use that change set to animate
a [SliverAnimatedList](https://api.flutter.dev/flutter/widgets/SliverAnimatedList-class.html).
