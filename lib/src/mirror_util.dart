// Copyright (c) 2013-2015, the dice project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

// Modified for d17 by Adam Stark <llamadonica@gmail.com>

part of d17;

/** Wrapper for [TypeMirror] to support multiple named registration for the same [Type] */
class TypeMirrorWrapper {
  final TypeMirror typeMirror;
  final TypeMirror adapteeTypeMirror;
  final String name;

  TypeMirrorWrapper(this.typeMirror, this.name) : adapteeTypeMirror = null;

  TypeMirrorWrapper.fromType(Type type, this.name)
      : adapteeTypeMirror = null,
        typeMirror = reflectType(type);

  TypeMirrorWrapper.asAdapter(
      this.typeMirror, this.adapteeTypeMirror, this.name);

  TypeMirrorWrapper.fromTypeAsAdapter(Type type, this.name, Type adapteeType)
      : adapteeTypeMirror = reflectType(adapteeType),
        typeMirror = reflectType(type);

  String get qualifiedName => symbolAsString(typeMirror.qualifiedName) +
      (name != null ? ' $name' : '') +
      (adapteeTypeMirror != null ? " :${adapteeTypeMirror.qualifiedName}" : '');

  get hashCode => qualifiedName.hashCode;

  bool operator ==(Object other) =>
      other is TypeMirrorWrapper && this.qualifiedName == other.qualifiedName;
}

class TypeMirrorBindingParameter {
  final TypeMirror typeMirror;
  final String name;

  TypeMirrorBindingParameter(this.typeMirror, this.name);

  String get qualifiedName => symbolAsString(typeMirror.qualifiedName) +
  (name != null ? ' $name' : '');

  get hashCode => qualifiedName.hashCode;

  bool operator ==(Object other) =>
  other is TypeMirrorBindingParameter && this.qualifiedName == other.qualifiedName;
}

// helpers
String symbolAsString(Symbol symbol) => MirrorSystem.getName(symbol);

Symbol stringAsSymbol(String string) => new Symbol(string);
