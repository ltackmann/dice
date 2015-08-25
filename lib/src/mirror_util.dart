// Copyright (c) 2013-2015, the dice project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

// Modified for d17 by Adam Stark <llamadonica@gmail.com>

part of d17;

/** Wrapper for [TypeMirror] to support multiple named registration for the same [Type] */
class TypeMirrorWrapper {
  final TypeMirror typeMirror;
  final String name;
  
  TypeMirrorWrapper(this.typeMirror, this.name);
  
  TypeMirrorWrapper.fromType(Type type, this.name) : typeMirror = reflectType(type);
  
  String get qualifiedName => symbolAsString(typeMirror.qualifiedName) + (name != null ? name : "");
  
  get hashCode => qualifiedName.hashCode;
  
  bool operator ==(TypeMirrorWrapper other) => this.qualifiedName == other.qualifiedName;
}

// helpers
String symbolAsString(Symbol symbol) => MirrorSystem.getName(symbol);

Symbol stringAsSymbol(String string) => new Symbol(string);
