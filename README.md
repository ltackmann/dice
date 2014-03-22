[![Build Status](https://drone.io/github.com/ltackmann/dice/status.png)](https://drone.io/github.com/ltackmann/dice/latest)

# Dice
Lightweight dependency injection framework for Dart.

## Getting Started
Dice consists of two parts. 
 * **Modules** containing your class registrations.
 * **Injectors** that uses the **Module** to inject instances into your code. 
 
The following example should get you startd:

**1.** Add the *Dice* to your **pubspec.yaml** and run **pub install**
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

**3.** Register types and classes in a module
```dart
	class ExampleModule extends Module {
	  configure() {
	    // register [CreditProcessor] as a singleton
	    register(CreditProcessor).toInstance(new CreditProcessorImpl());
	    // register [BillingService] so a new version is created each time its requested
	    register(BillingService).toType(BillingServiceImpl);
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

## Dependency Injection with Dice 
You can use the **@inject** annotation to mark objects and functions for injection the following ways:

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

The injected objects are configured by extending the **Module** class and using one its *register* functions

 * ```register(MyType).toInstance(object)``` register type **MyType** to existing object (singleton injections)
 * ```register(MyType).toType(MyType)``` register type **MyType** to an (possible alternative) class implementing it.
 * ```register(MyTypedef).toFunction(function)``` register a **typedef** to a function matching it.
 * ```register(MyType).toBuilder(() => new MyType())``` register **MyType** to function that can build instances of it 


## Named Injections
Dice supports named injections by using the **@Named** annotation. Currently this annotation 
works everywhere the **@inject** annotation works, except for constructors. 

```dart
	class MyClass {
      	@inject
      	@Named('my-special-implementation')
      	SomeClass _someClass;
   	}
```

The configuration is as before except you now use method **namedRegister** in your **Module** implementation.

 * ```namedRegister(MyType, "my-name").toInstace(object)```
 * ```namedRegister(MyType, "my-name").toType(MyType)``` 
 * ```namedRegister(MyTypedef, "my-name").toFunction(function)``` 
 * ```namedRegister(MyType, "my-name").toBuilder(() => new MyType())```
 

## Advanced Features
 * **Get instances directly** Instead of using the **@inject** annotation to resolve injections you can use the injectors **getInstance** method
```dart
   MyClass instance = injector.getInstance(MyClass);
```

 * **Get named instances directly** Instead of using the **@Named** annotation to resolve named injections you can use the injectors **getNamedInstance** method 
```dart
   MyType instance = injector.getNamedInstance(MyType, "my-name");
```

 * **To register and resole configuration values** You can use named registrations to inject configuration values into your application.
```dart
	class TestModule extends Module {
    	configure() {
			namedRegister(String, "web-service-host").toInstace("http://test-service.name");
		}
	}
	
	// application code
	String get webServiceHost => injector.getNamedInstance(String, "web-service-host");
``` 

 * **Registrering dependencies at runtime** You can register dependencies at runtime by accessing the **module** property on the **Injector** instance.
```dart
	 injector.module.register(User).toInstance(user);
	 :
	 var user = injector.getInstance(User);
``` 

 * **Using multiple modules** You can compose mudules using the **Injector.fromModules** constructor
```dart
	class MyModule extends Module {
    	configure() {
			register(MyClass).toType(MyClass);
		}
	}
	
	class YourModule extends Module {
    	configure() {
			register(YourClass).toType(YourClass);
		}
	}
	
	var injector = new Injector.fromModules(new MyModule(), new YourModule());
	var myClass = injector.getInstance(MyClass);
	var yourClass = injector.getInstance(YourClass);
``` 
 
 
 
