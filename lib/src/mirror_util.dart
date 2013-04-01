// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/**
 * Implements hashcode / equals for a TypeMirror.
 */
class TypeMirrorWrapper {
  final TypeMirror typeMirror;
  
  TypeMirrorWrapper(this.typeMirror);
  TypeMirrorWrapper.fromType(Type type) : typeMirror = getClassMirrorForType(type);
  
  get hashCode => typeMirror.qualifiedName.hashCode;
  bool operator ==(TypeMirrorWrapper other) => typeMirror.qualifiedName == other.typeMirror.qualifiedName;
}

// Inspired from Dado
ClassMirror getClassMirrorForType(Type type) {
  // Hack ! Waiting for a true method in dart:mirrors
  var name = type.toString();
  return currentMirrorSystem().libraries.values
      .where((lib) => lib.classes.containsKey(name))
      .map((lib) => lib.classes[name])
      .first;
}
