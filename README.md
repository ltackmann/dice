[![Build Status](https://travis-ci.org/ltackmann/dice.svg)](https://travis-ci.org/ltackmann/dice)
[![Coverage Status](https://coveralls.io/repos/ltackmann/dice/badge.svg?branch=master&service=github)](https://coveralls.io/github/ltackmann/dice?branch=master)

# D17
Lightweight dependency injection framework for Dart.

## Getting Started
D17 consists of two parts.
 * **Modules** containing your class registrations.
 * **Injectors** that uses the **Module** to inject instances into your code. 
 
The following example should get you startd:

**1.** Add *D17* to your **pubspec.yaml** and run **pub install**
```yaml
dependencies:
   d17:
    git:
      ref: master
      url: https://github.com/llamadonica/d17.git
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

The injected objects are configured ether by extending the **Module** class and using one its *register* functions or directly on the **Injector**.

 * register type **MyType** to existing object (singleton injections)
```dart
register(MyType).toInstance(object)
```

 * register type **MyType**.
```dart
register(MyType)
```

 * register interface **MyType** to a class implementing it.
```dart
register(MyType).toType(MyTypeImpl)
```

 * register a **typedef** to a function matching it.
```dart
register(MyTypedef).toFunction(function)
```

 * register **MyType** to function that can build instances of it
```dart
register(MyType).toBuilder(() => new MyType())
``` 


## Named Injections
Dice supports named injections by using the **@Inject(name: 'foo')** annotation. Currently this annotation
works everywhere the **@inject** annotation works, except for constructors. 

```dart
class MyClass {
  @Inject(name: 'my-special-implementation')
  SomeClass _someClass;
}
```

The configuration is as before except you now provide an additional **name** paramater.

```dart
register(MyType, "my-name").toType(MyTypeImpl)
```


## Advanced Features
 * **Get instances directly** Instead of using the **@inject** annotation to resolve injections you can use the injectors **getInstance** method.
```dart
MyClass instance = injector.getInstance(MyClass);
```

 * **Get named instances directly** Instead of using the **@Named** annotation to resolve named injections you can use the injectors **getInstance** method with its **name** parameter. 
```dart
MyType instance = injector.getInstance(MyType, "my-name");
```

 * **To register and resole configuration values** You can use named registrations to inject configuration values into your application.
```dart
class TestModule extends Module {
  	configure() {
		register(String, "web-service-host").toInstace("http://test-service.name");
	}
}

// application code
String get webServiceHost => injector.getInstance(String, "web-service-host");
``` 

 * **Registering dependencies at runtime** You can register dependencies at runtime directly on the **Injector**.
```dart
 injector.register(User).toInstance(user);
 var user = injector.getInstance(User);
``` 

 * **Unregistering dependencies at runtime** You can unregister dependencies at runtime using the **unregister** method on the **Injector**.
```dart
injector.unregister(User);
``` 

 * **Using multiple modules** You can compose modules using the **Injector.fromModules** constructor.
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

var injector = new Injector.fromModules([new MyModule(), new YourModule()]);
var myClass = injector.getInstance(MyClass);
var yourClass = injector.getInstance(YourClass);
```
 
 * **Joining injectors** You can join multiple injector instances to one using the **Injector.fromInjectors** constructor.
```dart
var myInjector = new Injector();
myInjector.register(MyClass).toType(MyClass);

var yourInjector = new Injector();
yourInjector.register(YourClass).toType(YourClass);

var injector = new Injector.fromInjectors([myInjector, yourInjector]);
var myClass = injector.getInstance(MyClass);
var yourClass = injector.getInstance(YourClass);
```
 
