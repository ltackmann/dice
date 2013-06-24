// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/** Implements hashcode / equals for a TypeMirror. */
class TypeMirrorWrapper {
  final TypeMirror typeMirror;
  
  TypeMirrorWrapper(this.typeMirror);
  TypeMirrorWrapper.fromType(Type type) : typeMirror = reflectClass(type);
  
  get hashCode => typeMirror.qualifiedName.hashCode;
  bool operator ==(TypeMirrorWrapper other) => typeMirror.qualifiedName == other.typeMirror.qualifiedName;
}

// helpers
String symbolAsString(Symbol symbol) => MirrorSystem.getName(symbol);

Symbol stringAsSymbol(String string) => new Symbol(string);
