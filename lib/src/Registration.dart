// Copyright (c) 2013, the Dice project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/** Registration between a [Type] and its instance creation. */
class Registration {
  /** Register object [instance] that will be returned when the type is requested */
  toInstance(var instance) {
    if(!_isClass(instance)) {
      throw new ArgumentError("only objects can be bound using 'toInstance'");
    }
    _builder = () => instance;
  }
  
  /** Register a [function] that will be returned when the type is requested */
  toFunction(var function) {
    if(_isClass(function)) {
      throw new ArgumentError("only functions can be bound using 'toFunction'");
    }
    _builder = () => function;
  }
  
  /** Register a [InstanceBuilder] that will emit new instances when the type is requested */
  toBuilder(TypeBuilder builder) {
    _builder = builder;
  }
  
  /** Register a [type] that will be instantiated when the type is requested */
  toType(Type type) {
    _builder = () => type;
  }
  
  bool _isClass(var instance) => reflect(instance).type is! FunctionTypeMirror;
  
  TypeBuilder _builder;
}

/** Function that builds instance of a bound types */
typedef dynamic TypeBuilder();
