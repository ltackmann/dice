[![Build Status](https://drone.io/github.com/ltackmann/dice/status.png)](https://drone.io/github.com/ltackmann/dice/latest)

Dice
====
Lightweight dependency injection framework for Dart.

Dice is a simple dependency injection framework. In dice you create **Module** instance and bind types/classes to
instances. You then pass the this module to an **Injector** which looks for **@inject** annotations and resolves 
them to the values bound in your module. 


# Quick Guide
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

for more information see the full example [here](example/example_app.dart).

Dependency Injection with Dice 
------------------------------
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

The actual values injected are configured by extending **Module** class and using one its binder functions

 * ```bind(MyType).toInstace(object)``` bind type **MyType** to existing object (this effectivly gives you singleton injections)
 * ```bind(MyType).toType(MyType)``` bind type **MyType** to an (possible alternative) class implementing it.
 * ```bind(MyTypedef).toFunction(function)``` bind a **typedef** to a function matching it.
 * ```bind(MyType).toBuilder(() => new MyType())``` bind **MyType** to a function that when executed returns a instance of it 

Instead of using the **@inject** annotation to resolve injections you can use the injectors **getInstance** method

```dart
   MyClass instance = injector.getInstance(MyClass);

```

Named Injections
----------------
Dice supports named injections by using the **@Named** annotation. Currently this annotation 
works everywhere the @inject annotation works, except for constructors. 

```dart
	class MyClass {
      	@inject
      	@Named('my-special-implementation')
      	SomeClass _someClass;
   	}
```

The configuration is as before except you now use method **namedBind** inside your **Module** implementation.

 * ```namedBind(MyType, "my-name").toInstace(object)```
 * ```namedBind(MyType, "my-name").toType(MyType)``` 
 * ```namedBind(MyTypedef, "my-name").toFunction(function)``` 
 * ```namedBind(MyType, "my-name").toBuilder(() => new MyType())```
 
Instead of using the **@Named** annotation to resolve named injections you can use the **Injector** directly 

```dart
   MyType instance = injector.getNamedInstance(MyType, "my-name");

```

Tips and Tricks
---------------
You can use named bindings to create a simple yet effective way of injecting configuration values into your application.

```dart
	class TestModule extends Module {
    	configure() {
			namedBind("web-service-host", String).toInstace("http://test-service.name");
		}
	}
	
	// application code
	String get webServiceHost => injector.getNamedInstance("web-service-host", String);
``` 
 
 
 