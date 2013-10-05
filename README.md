[![Build Status](https://drone.io/github.com/ltackmann/dice/status.png)](https://drone.io/github.com/ltackmann/dice/latest)

Dice
====
Lightweight dependency injection framework for Dart.

# Quick Guide
-----------
Dice is configured by creating a **Module** instance that acts as factory binding your classes to instances. 
Modules are passed to an **Injector** which looks for **@inject** annotations and resolves them to instances 
bound in your module. It's really quite simple:

**1.** Add the folowing to your **pubspec.yaml** and run **pub install**
```yaml
    dependencies:
      dice: any
```

**2.** Create some classes and interfaces to inject
```dart
	class BillingServiceImpl implements BillingService {
	  @inject
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
You can use the **@inject** annotation to mark values for injection the following ways:

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

The actual values injected are configured by extending the **Module** class and using one its binder functions

 * ```bind(MyType).toInstace(object)``` bind type **MyType** to existing object (singleton injections)
 * ```bind(MyType).toType(MyType)``` bind type **MyType** to an (possible alternative) class implementing it.
 * ```bind(MyTypedef).toFunction(function)``` bind a **typedef** to a function matching it.
 * ```bind(MyType).toBuilder(() => new MyType())``` bind **MyType** to function that can build instances of it 


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
 

Tips and Tricks
---------------
**Tip 1.** Instead of using the **@inject** annotation to resolve injections you can use the injectors **getInstance** method
```dart
   MyClass instance = injector.getInstance(MyClass);

```

**Tip 2.** Instead of using the **@Named** annotation to resolve named injections you can use the **Injector** directly 
```dart
   MyType instance = injector.getNamedInstance(MyType, "my-name");
```

**Tip 3.** You can use named bindings to create a simple yet effective way of injecting configuration values into your application.
```dart
	class TestModule extends Module {
    	configure() {
			namedBind(String, "web-service-host").toInstace("http://test-service.name");
		}
	}
	
	// application code
	String get webServiceHost => injector.getNamedInstance(String, "web-service-host");
``` 


 
 
 
