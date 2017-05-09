// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of dice;

/// Wrapper for [TypeMirror] to support multiple named registration for the same [Type] */
class TypeMirrorWrapper {
    final TypeMirror typeMirror;

    final String name;
    final TypeMirror annotationTypeMirror;

    TypeMirrorWrapper(this.typeMirror, this.name, this.annotationTypeMirror);

    TypeMirrorWrapper.fromType(final Type type, this.name, final Type annotation)
        : typeMirror = reflectType(type),
            annotationTypeMirror = annotation != null ? reflectType(annotation) : null;

    String get qualifiedName =>
        symbolAsString(typeMirror.qualifiedName)
            + (name != null ? "#$name" : "")
            + (annotationTypeMirror != null
                ? "#${symbolAsString(annotationTypeMirror.qualifiedName)}" : "");

    get hashCode => qualifiedName.hashCode;

    bool operator ==(TypeMirrorWrapper other) => this.qualifiedName == other.qualifiedName;
}

// helpers
String symbolAsString(Symbol symbol) => MirrorSystem.getName(symbol);

Symbol stringAsSymbol(String string) => new Symbol(string);
