[![Build Status](https://travis-ci.org/ltackmann/dice.svg)](https://travis-ci.org/ltackmann/dice)
[![Coverage Status](https://coveralls.io/repos/ltackmann/dice/badge.svg?branch=master&service=github)](https://coveralls.io/github/ltackmann/dice?branch=master)

# Dice
Lightweight dependency injection framework for Dart.

## Getting Started
Dice consists of two parts. 
 * **Modules** containing your class registrations.
 * **Injectors** that uses the **Module** to inject instances into your code. 
 
The following example should get you started:

**1.** Add the *Dice* to your **pubspec.yaml** and run **pub install**
```yaml
dependencies:
   dice: any
```

**2.** Create some classes and interfaces to inject
```dart
@injectable
abstract class BillingService {
    Receipt chargeOrder(Order order, CreditCard creditCard);    
} 

@injectable
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
    
  @override    
  configure() {
    // register [CreditProcessor] as a singleton
    bind(CreditProcessor).to(CreditProcessorImpl).asSingleton();
    
    // register [BillingService] so a new version is created each time its requested
    register(BillingService).toType(BillingServiceImpl);
  }
}
```

**4.** Run it
```dart
import "package:dice/dice.dart";
main() {
	final injector = new Injector(new ExampleModule());
	final billingService = injector.getInstance(BillingService);
	final creditCard = new CreditCard("VISA");
	final order = new Order("Dart: Up and Running");
	billingService.chargeOrder(order, creditCard);
}
```

for more information see the full example [here](samples/cmdline/app/example_app.dart).

## Dependency Injection with Dice 

You can use the **@injectable** annotation to mark classes as **injectable**,
use **@inject** annotation to mark objects, functions and constructors for injection the following ways:
(It is not necessary to mark a default constructor with **@inject** - only complex CTORs must be marked)

 * Injection of public and private fields (object/instance variables)
```dart
@injectable
class MyOtherClass {
  @inject
  SomeClass field;
  
  @inject
  SomeOtherClass _privateField;
}
```
  
 * Injection of constructor parameters 
```dart 
@injectable
class MyClass {
  @inject
  MyClass(this.field);

  MyOtherClass field;
}
```
 
 * Injection of public and private setters 
```dart
@injectable
class SomeClass {
  @inject
  set value(SomeOtherClass val) => _privateValue = val;
  	
  @inject
  set _value(SomeOtherClass val) => _anotherPrivateValue = val;

  SomeOtherClass _privateValue, _anotherPrivateValue;
}
```

The injected objects are configured either by extending the **Module** class and using one 
its *register* functions or directly on the **Injector**.

 * register type **MyType**.
```dart
register(MyType)
```

 * register interface **MyType** to a class implementing it.
```dart
register(MyType).toType(MyTypeImpl)
```

 * register a singleton
```dart
register(MyType).to(MySuperType).asSingleton();
```

 * register type **MyType** to existing object (another way for singleton injections)
```dart
register(MyType).toInstance(object)
```

 * register a **typedef** to a function matching it.
```dart
register(MyTypedef).toFunction(function)
```

 * register **MyType** to function that can build instances of it
```dart
register(MyType).toBuilder(() => new MyType())
``` 

 * use Module to install other modules configuration
```dart
class MyApplicationModule extends Module {
  @override
  configure() {
    install(new ComponentModule());
    
    bind(Emailer).to(EmailerToGMX).asSingleton();
  }
}
```

## Named Injections
Dice supports named injections by using the **@Named** annotation. Currently this annotation 
works everywhere the **@inject** annotation works. 

```dart
class MyClass {
  @inject
  @Named('my-special-implementation')
  SomeClass _someClass;
}
```

The configuration is as before except you now provide an additional **name** paramater.

```dart
register(MyType, named: "my-name").toType(MyTypeImpl)
```

The configuration is as before except you now provide an additional **name** paramater.

## Annotated (typed) Injections
You can also use other classes for annotation. 
works everywhere the **@inject** annotation works. 

```dart
@injectable
class UrlGoogle { const UrlGoogle(); }

@injectable
class UrlFacebook { const UrlFacebook(); }

class MyModule extends Module {
  @override    
  configure() {
    // annotated
    register(String,annotatedWith: UrlGoogle ).toInstance("http://www.google.com/");
    register(String,annotatedWith: UrlFacebook ).toInstance("http://www.facebook.com/");
  }
}

@injectable
class MyClass {
  @inject
  @UrlGoogle()
  String url;
}
```

The configuration is as before except you now provide an additional **annotation**.


## Advanced Features
 * **Get instances directly** Instead of using the **@inject** annotation to resolve injections you 
 can use the injectors **getInstance** method.
```dart
MyClass instance = injector.getInstance(MyClass);
```

 * **Get named instances directly** Instead of using the **@Named** annotation to resolve named 
 injections you can use the injectors **getInstance** method with its **named** parameter. 
```dart
MyType instance = injector.getInstance(MyType, named: "my-name");
```

 * **Get annotated instances directly** Instead of using the appropriate annotation to resolve 
 annotated injections you can use the injectors **getInstance** method with its **annotatedWith** parameter. 
```dart
String url = injector.getInstance(MyType, annotatedWith: UrlGoogle);
```

 * **To register and resole configuration values** You can use named or annotated registrations 
 to inject configuration values into your application.
```dart
class TestModule extends Module {
  	configure() {
		register(String, named: "web-service-host").toInstace("http://test-service.name");
		register(String, annotatedWith: UrlGoogle ).toInstance("http://www.google.com/");
	}
}

// application code
String get webServiceHost => injector.getInstance(String, named: "web-service-host");
String get webServiceHost2 => injector.getInstance(String, annotatedWith: UrlGoogle);
``` 

 * **Constructor injection**
Dice also support constructors with optional params.

```dart
@injectable
class MyClass {
  String getName() => "MyClass";
}

@injectable
class CTOROptionalInjection extends MyClass {
  final String url;
  final String lang;

  @inject
  CTOROptionalInjection(@UrlGoogle() final String this.url,[ final String language ])
      : lang = language ?? "C++";

  @override
  String getName() => "CTORInjection - $url ($lang)";
}

final injector = new Injector()
  ..register(String,annotatedWith: UrlGoogle ).toInstance("http://www.google.com/")
  ..register(MyClass).toType(CTOROptionalInjection)
;
final MyClass mc = injector.getInstance(MyClass);
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

 * **Install other modules within main module**

```dart
class MyModule extends Module {
  	configure() {
		register(MyClass).toType(MyClass);
	}
}

class MyMainModule extends Module {
  	configure() {
  	    install(new MyModule());
		register(YourClass).toType(YourClass);
	}
}

var injector = new Injector( new MyMainModule());
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
```             `
 
## Compatibility / migration from di:package

To make migration easier we provide the following functions:

 * `Injector.bind` is the same as `Injector.register`. 
 * `Module.bind` is the same as `Module.register`
 * `Injector.get` is the same as `Injector.getInstance`
 * `Registration.to` is the same as `Registration.toType`

Be aware that `Injector.register` and may become
depreciated in one of the next releases.

Prefer the `bind`, `to and the `get` version over its equivalent.   