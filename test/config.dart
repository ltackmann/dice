// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.
library dice_test_config;

import 'package:logging/logging.dart';
//import 'package:logging_handlers/logging_handlers_shared.dart';

void configLogging({final Level defaultLogLevel: Level.INFO }) {
    //hierarchicalLoggingEnabled = false; // set this to true - its part of Logging SDK

    // now control the logging.
    // Turn off all logging first
    Logger.root.level = defaultLogLevel;
    //Logger.root.onRecord.listen(new LogPrintHandler());
}

