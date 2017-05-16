// Copyright (c) 2017, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of dice;

String _ASSERT_REGISTER_TYPE_NOT_MARKED(final Type type)
    => "You are registering '$type' but this type is not marked as '@injectable'";

String _ASSERT_REGISTER_ANNOTATION_NOT_MARKED(final Type type, final Type annotatedWith)
    =>  "You are registering '$type' to be annotaded with $annotatedWith but "
            "this annotation is not marked as '@injectable'";

String _ASSERT_GET_TYPE_NOT_MARKED(final Type type)
    => "You want an instance for '$type' but this type is not marked as '@injectable'";

String _ASSERT_GET_ANNOTATION_NOT_MARKED(final Type type, final Type annotatedWith)
    =>  "You want an instance for '$type', annotaded with $annotatedWith, but "
        "this annotation is not marked as '@injectable'";

