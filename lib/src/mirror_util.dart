// Copyright (c) 2017, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of dice;

final Logger _logger = new Logger('dice._validate');

/// Wrapper for [TypeMirror] to support multiple named registration for the same [Type] */
class TypeMirrorWrapper {
//    final TypeMirror _typeMirror;
//
//    final String _name;
//
//    final TypeMirror _annotationTypeMirror;

    final String qualifiedName;

    factory TypeMirrorWrapper(final TypeMirror typeMirror, final String name, final TypeMirror annotationTypeMirror) {
        return new TypeMirrorWrapper._internal(
            TypeMirrorWrapper._createQualifiedName(typeMirror.qualifiedName, name, annotationTypeMirror)
        );
    }

    factory TypeMirrorWrapper.fromType(final Type type, final String name, final Type annotationType) {
        return new TypeMirrorWrapper._internal(
            TypeMirrorWrapper._createQualifiedName(
                inject.canReflectType(type) ? inject.reflectType(type).qualifiedName : type.toString(),
                name,
                (annotationType != null ? inject.reflectType(annotationType) : null))
        );
    }

    get hashCode => qualifiedName.hashCode;

    bool operator ==(final Object other) => other is TypeMirrorWrapper
          && this.qualifiedName == other.qualifiedName;

    // private CTOR
    TypeMirrorWrapper._internal(this.qualifiedName);

    static String _createQualifiedName(final String qualifiedName, final String name, final TypeMirror annotationTypeMirror) {
        return qualifiedName
            + (name != null ? "#$name" : "")
            + (annotationTypeMirror != null
            ? "#${(annotationTypeMirror.qualifiedName)}" : "");
    }
}

// helpers
String symbolAsString(final Symbol symbol) => symbol.toString();

Symbol stringAsSymbol(final String string) => new Symbol(string);

bool isInjectable(final Type type) {
    final List<Object> metadata = inject.reflectType(type).metadata;
//    metadata.forEach((final Object object) {
//        _logger.info(object.runtimeType);
//    });

    final bool hasAnnotation = metadata.firstWhere((final Object object) => object is InjectAnnotation,orElse: null) != null;
//    _logger.info("Has Annotation $hasAnnotation");
    
    return hasAnnotation;
}

/// Makes some basic validation checks.
/// if [codition] is false an [ArgumentError] is thrown
/// 
/// [assert] does not work for this because it is always off by default
/// See: https://github.com/dart-lang/pub/issues/932
void _validate(final bool condition,final String message) {
    if(!condition) {
        throw new ArgumentError(message);
    }
}
