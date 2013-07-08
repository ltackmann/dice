[![Build Status](https://drone.io/github.com/ltackmann/dice/status.png)](https://drone.io/github.com/ltackmann/dice/latest)

Dice
====
Lightweight dependency injection framework for Dart.

Injection Types
---------------

Dice supports the following injection forms

 * Injection of public and private fields (object/instance variables)
```dart
	class MyOtherClass {
    	@Inject
      	SomeClass field;
      	@Inject
      	SomeOtherClass _privateField;
   	}
```
  
 * Injection of constructors (if no constructor is annotated with **@Inject** then the default is used)
```dart 
	class MyClass {
 		@Inject
 		MyClass(this.field);
 		
 		MyOtherClass field;
 	}
```
 
 * Injection of public setters 
```dart
	class SomeClass {
      	@Inject
      	set value(SomeOtherClass val) => _privateVal = val;

      	SomeOtherClass _privateVal;
	}
```


Named injections are not supported yet but we are working on fixing this.

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
	  @Inject
	  CreditProcessor _processor;
	  
	  Receipt chargeOrder(Order order, CreditCard creditCard) {
	    if(!_processor.validate(creditCard)) {
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
	    bind(BillingService).toType(BillingServiceImpl);
	  }
	}
```

**4.** Run it
```dart
    import "package:dice/dice.dart";
	main() {
	  	var injector = new Injector(new ExampleModule());
	  	var billingService = injector.getInstance(BillingService);
	  	var creditCard = new CreditCard("VISA");
	  	var order = new Order("Dart: Up and Running");
	  	billingService.chargeOrder(order, creditCard);
	}
```

for more information see the example application [here](example/example_app.dart).
