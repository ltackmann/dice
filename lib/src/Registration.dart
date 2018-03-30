// Copyright (c) 2017, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of dice;

/// Function that builds instance of a bound types
typedef dynamic TypeBuilder();

/// Registration between a [Type] and its instance creation.
class Registration {
  /// Create Registration defaulting to [type]
  Registration(Type type) {
    toType(type);
  }

  /// Register object [instance] that will be returned when the type is requested
  void toInstance(var instance) {
    if (!_isClass(instance)) {
      throw new ArgumentError("only objects can be bound using 'toInstance'");
    }
    _builder = () => instance;
  }

  /// Register a [function] that will be returned when the type is requested
  void toFunction(var function) {
    if (_isClass(function)) {
      throw new ArgumentError("only functions can be bound using 'toFunction'");
    }
    _builder = () => function;
  }

  /// Register a [InstanceBuilder] that will emit new instances when the type is requested
  void toBuilder(TypeBuilder builder) {
    _builder = builder;
  }

  /// Register a [type] that will be instantiated when the type is requested
  Registration toType(Type type) {
    _builder = () => type;
    return this;
  }

  /// Most common way to register something.
  /// This is a shortcut to [toType]
  Registration to(Type type) => toType(type);

  /// Create only one instance
  void asSingleton() {
    _asSingleton = true;
  }

  bool _isClass(var instance) => reflect(instance).type is! FunctionTypeMirror;

  TypeBuilder _builder;

  bool _asSingleton = false;

  /// Remember the instance in case we marked the Registration for "singleton"
  var _instance = null;
}

class RegistrationMulti extends Registration {
  Set<Registration> _registrations = new Set();

  /// Create Registration defaulting to [type]
  RegistrationMulti(Type type) : super(type);

  bool _asSingleton = true;

  /// Remember the instance in case we marked the Registration for "singleton"
  var _instance = null;

  void addRegistration(Registration registration) {
    _registrations.add(registration);
  }
}
