// Copyright (c) 2013-2015, the dice project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

// Modified for d17 by Adam Stark <llamadonica@gmail.com>

part of d17;

/** Registration between a [Type] and its instance creation. */
class Registration {
  /** Create Registration defaulting to [type] */
  Registration(Type type) {
    toType(type);
  }
  
  /** Register object [instance] that will be returned when the type is requested */
  toInstance(var instance) {
    if(!_isClass(instance)) {
      throw new ArgumentError("only objects can be bound using 'toInstance'");
    }
    _builder = () => instance;
    _finalType = reflectType(instance.runtimeType);
  }
  
  /** Register a [function] that will be returned when the type is requested */
  toFunction(var function) {
    if(_isClass(function)) {
      throw new ArgumentError("only functions can be bound using 'toFunction'");
    }
    _builder = () => function;
    var functionReflector = reflect(function);
    _finalType = functionReflector.type;
  }
  
  /** Register a [InstanceBuilder] that will emit new instances when the type is requested */
  toBuilder(TypeBuilder builder) {
    _builder = builder;
    var functionReflector = reflect(builder);
    if (functionReflector is ClosureMirror) {
      _finalType = functionReflector.function.returnType;
    } else {
      throw new ArgumentError("only functions can be bound using 'toBuilder'");
    }
  }
  
  /** Register a [type] that will be instantiated when the type is requested */
  toType(Type type) {
    _builder = () => type;
    _finalType = reflectType(type);
  }
  
  bool _isClass(var instance) => reflect(instance).type is! FunctionTypeMirror;
  
  TypeBuilder _builder;
  TypeMirror _finalType;
}

/** Function that builds instance of a bound types */
typedef dynamic TypeBuilder();
