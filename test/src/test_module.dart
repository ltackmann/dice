// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of dice_test;

class MyModule extends Module {

  configure() {
    register(MyClass).toInstance(new MyClass());
    register(MyOtherClass).toBuilder( () => new MyOtherClass());
    register(MyClassToInject);

    // Singleton
    register(MySingletonClass).toType(MySpecialSingletonClass).asSingleton();

    // named
    register(MyClass, named: "MySpecialClass").toType(MySpecialClass);
    //- register(String, named: "google").toInstance("http://www.google.com/");

    // annotated
    //- register(String,annotatedWith: UrlGoogle ).toInstance("http://www.google.com/");
    //- register(String,annotatedWith: UrlFacebook ).toInstance("http://www.facebook.com/");
  }
}

class YourModule extends Module {
  configure() {
    register(YourClass).toType(YourClass);
  }
}

class MySingletonModule extends Module {
    configure() {
        // Singleton
        register(AnotherSingletonClass).asSingleton();
    }
}

class MyModuleForInstallation extends Module {

  @override
  configure() {
    install(new MyModule());

    register(MySingletonClass).toType(MySpecialSingletonClass2);
  }
}

@inject
class MyClassToInject {
  // constructors
  @inject
  MyClassToInject.inject(/*MyClass constructorParameterToInject*/) {
    //injections["constructorParameterToInject"] = constructorParameterToInject;
  }

  // setters
  @inject
  set setterToInject(MyClass setterToInject) => injections["setterToInject"] = setterToInject;

  @inject
  set _setterToInject(MyClass setterToInject) => injections["_setterToInject"] = setterToInject;

  set setterNotToInject(MyClass setterNotToInject) => injections["setterNotToInject"] = setterNotToInject;
  
  set _setterNotToInject(MyClass setterNotToInject) => injections["_setterNotToInject"] = setterNotToInject;

  // TODO named setter injection

  // instance variables
  @inject
  MyClass variableToInject;

  @inject
  MyOtherClass _variableToInject;

  MyClass variableNotToInject;
  MyOtherClass _variableNotToInject;

  @inject
  @Named("MySpecialClass")
  MyClass namedVariableToInject;

  @inject
  @Named("MySpecialClass")
  MyClass _namedVariableToInject;

  // Map to trace injections from setters or constructors
  Map injections = new Map();

  @inject
  @Named("google")
  String url1;

  @inject
  @UrlGoogle()
  String url2;

  @inject
  @UrlFacebook()
  String url3;

  bool assertInjections() {
    // constructors
    //-var constructorsInjected = (injections[r'constructorParameterToInject'] != null);

    // variables
    var variablesToInject = (variableToInject != null && _variableToInject != null);
    var variablesNotToInject = (variableNotToInject == null && _variableNotToInject == null);
    var namedVariablesToInject = (_namedVariableToInject != null && namedVariableToInject != null);
    var variablesInjected = variablesToInject && variablesNotToInject && namedVariablesToInject;

    var stringInjectedByName = url1 != null && url1 == "http://www.google.com/";
    var stringInjectedByAnnotation1 = url2 != null && url2 == "http://www.google.com/";
    var stringInjectedByAnnotation2 = url3 != null && url3 == "http://www.facebook.com/";

    // setters
    // TODO && injections[r'_setterToInject'] != null
    var settersToInject = (injections[r'setterToInject'] != null);
    var settersNotToInject = (injections[r'setterNotToInject'] == null && injections[r'_setterNotToInject'] == null);
    var settersInjected = settersToInject && settersNotToInject;

    return /*constructorsInjected &&*/ variablesInjected && settersInjected && stringInjectedByName &&
        stringInjectedByAnnotation1 && stringInjectedByAnnotation2;
  }
}

@inject
//@Injectable()
class MyClass {
  String getName() => "MyClass";
}

@inject
class MyOtherClass {
  String getName() => "MyOtherClass";
}

@inject
class MySpecialClass implements MyClass {
  String getName() => "MySpecialClass";
}

@inject
class YourClass {
  String getName() => "YourClass";
}

@inject
class MySingletonClass {
    static int instanceCounter = 1;

    /// Remember the actual instance
    final int instanceID;

    MySingletonClass() : instanceID = instanceCounter {
        instanceCounter++;
    }

    String getName() => "MySingletonClass - InstanceID: ${instanceID}";
}

@inject
class MySpecialSingletonClass extends MySingletonClass {
    String getName() => "MySpecialSingletonClass - InstanceID: ${instanceID}";
}

@inject
class MySpecialSingletonClass2 extends MySingletonClass {
    String getName() => "MySpecialSingletonClass2 - InstanceID: ${instanceID}";
}

@inject
class AnotherSingletonClass {
    String getName() => "AnotherSingletonClass";
}

@inject
class MetaTestClass extends MyClass {
    String getName() => "MetaTestClass";
}

@inject
class CTORInjection extends MyClass {
    final String url;
    final String lang;

    @inject
    CTORInjection(@UrlGoogle() final String this.url,@Named("language") final String language)
        : lang = language;

    @override
    String getName() => "CTORInjection - $url ($lang)";
}

@inject
class CTOROptionalInjection extends MyClass {
    final String url;
    final String lang;

    @inject
    CTOROptionalInjection(@UrlGoogle() final String this.url,[ final String language ])
        : lang = language ?? "C++";

    @override
    String getName() => "CTORInjection - $url ($lang)";
}

// Class Annotations for URLs
@inject
class UrlGoogle { const UrlGoogle(); }

@inject
class UrlFacebook { const UrlFacebook(); }

class IAmAMixin { }
class MyStoreClass extends MyClass with IAmAMixin {}

