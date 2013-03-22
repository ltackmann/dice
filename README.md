[![Build Status](https://drone.io/github.com/ltackmann/dice/status.png)](https://drone.io/github.com/ltackmann/dice/latest)

Dice
====
Lightweight dependency injection framework for Dart.

Quick Guide
-----------

1. Add the folowing to your **pubspec.yaml** and run **pub install**
```
    dependencies:
      dice:
        git: git://github.com/ltackmann/dice.git
```

2. Create a module where you bind types to their instances
```dart
    class MyModule extends Module {
      @override
      configure() {
        // always return the same instance
        bind(MyClass).toInstance(new MyClass());
        // invoke builder everytime type is requested
        bind(MyOtherClass).toBuilder(() => new MyOtherClass());
      }
    }
```

3. Run it
```dart
    import "package:dice/dice.dart";
    main() {
      var injector = new Injector(new MyModule());
      var myClass = injector.getInstance(MyClass);
      var myOtherClass = injector.getInstance(MyOtherClass);
    }
```
