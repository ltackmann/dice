[![Build Status](https://drone.io/github.com/ltackmann/dice/status.png)](https://drone.io/github.com/ltackmann/dice/latest)

Dice
====
Lightweight dependency injection framework for Dart.

Injection Types
---------------

Dice supports the following injection forms

 * Fields starting with $ and _$ are injected
 * Setters starting $ are injected
 * Variables starting with $ and _$ are injected
 
Injection of parameters is unsupported as Dart's mirror system cannot handle these yet.

Quick Guide
-----------

**1.** Add the folowing to your **pubspec.yaml** and run **pub install**
```yaml
    dependencies:
      dice: any
```

**2.** Create some classes and interfaces to inject
```dart
	class BillingServiceImpl implements BillingService {
	  // fields starting with $ and _$ gets injected
	  CreditProcessor _$processor;
	  
	  Receipt chargeOrder(Order order, CreditCard creditCard) {
	    if(!_$processor.validate(creditCard)) {
	      throw new ArgumentError("payment method not accepted");
	    }
	    // :
	  }
	}
```

**3.** Register the type/class bindings in a module
```dart
	class ExampleModule extends Module {
	  configure() {
	    // bind CreditProcessor to a singleton
	    bind(CreditProcessor).toInstance(new CreditProcessorImpl());
	    // bind BillingService to a prototype
	    bind(BillingService).toType(new BillingServiceImpl());
	  }
	}
```

**4.** Run it
```dart
    import "package:dice/dice.dart";
    main() {
	  var injector = new Injector(new ExampleModule());
	  injector.getInstance(BillingService).then((BillingService billing) {
	    var creditCard = new CreditCard("VISA");
	    var order = new Order("Dart: Up and Running");
	    billing.chargeOrder(order, creditCard);
	  });
	}
```

for more information see the example application [here](example/example_app.dart).
