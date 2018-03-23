// Copyright (c) 2017, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of dice_cmdline_example;

@di.inject
abstract class Emailer {
    void sendMail();
}

class EmailerToGoogle implements Emailer {
    @override
    void sendMail() {
        print("Send mail to Google");
    }
}

class EmailerToGMX implements Emailer {
    @override
    void sendMail() {
        print("Send mail to GMX");
    }
}

@di.inject
class EventScheduler {

    final Emailer _emailer;

    @di.inject
    EventScheduler(this._emailer);

    void send() => _emailer.sendMail();
}