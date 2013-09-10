[![Build Status](https://drone.io/github.com/ltackmann/dice/status.png)](https://drone.io/github.com/ltackmann/dice/latest)

Dice
====
Lightweight dependency injection framework for Dart.

Dice is a simple dependency injection framework. In dice you create **Module** instance and bind types/classes to
instances. You then pass the this module to an **Injector** which looks for **@inject** annotations and resolves 
them to the values bound in your module. 

Dependency Injection 
--------------------

In Dice you can use the **@inject** annotation to mark values for injection in the following way:

 * Injection of public and private fields (object/instance variables)
```dart
	class MyOtherClass {
    	@inject
      	SomeClass field;
      	@inject
      	SomeOtherClass _privateField;
   	}
```
  
 * Injection of constructor parameters 
```dart 
	class MyClass {
 		@inject
 		MyClass(this.field);
 		
 		MyOtherClass field;
 	}
```
 
 * Injection of public and private setters 
```dart
	class SomeClass {
      	@inject
      	set value(SomeOtherClass val) => _privateValue = val;
      	
      	@inject
      	set _value(SomeOtherClass val) => _anotherPrivateValue = val;

      	SomeOtherClass _privateValue, _anotherPrivateValue;
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
