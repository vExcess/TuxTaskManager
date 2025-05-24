import '../lib/font.dart';

List<dynamic> tests = [
    '20px Arial',
    { "size": 20, "families": ['arial'] },
    '20pt Arial',
    { "size": 26.666667461395264, "families": ['arial'] },
    '20.5pt Arial',
    { "size": 27.333334147930145, "families": ['arial'] },
    '20% Arial',
    { "size": 3.1999999284744263, "families": ['arial'] },
    '20mm Arial',
    { "size": 75.59999942779541, "families": ['arial'] },
    '20px serif',
    { "size": 20, "families": ['serif'] },
    '20px sans-serif',
    { "size": 20, "families": ['sans-serif'] },
    '20px monospace',
    { "size": 20, "families": ['monospace'] },
    '50px Arial, sans-serif',
    { "size": 50, "families": ['arial', 'sans-serif'] },
    'bold italic 50px Arial, sans-serif',
    { "style": 1, "weight": 700, "size": 50, "families": ['arial', 'sans-serif'] },
    '50px Helvetica ,  Arial, sans-serif',
    { "size": 50, "families": ['helvetica', 'arial', 'sans-serif'] },
    '50px "Helvetica Neue", sans-serif',
    { "size": 50, "families": ['Helvetica Neue', 'sans-serif'] },
    '50px "Helvetica Neue", "foo bar baz" , sans-serif',
    { "size": 50, "families": ['Helvetica Neue', 'foo bar baz', 'sans-serif'] },
    "50px 'Helvetica Neue'",
    { "size": 50, "families": ['Helvetica Neue'] },
    'italic 20px Arial',
    { "size": 20, "style": 1, "families": ['arial'] },
    'oblique 20px Arial',
    { "size": 20, "style": 2, "families": ['arial'] },
    'normal 20px Arial',
    { "size": 20, "families": ['arial'] },
    '300 20px Arial',
    { "size": 20, "weight": 300, "families": ['arial'] },
    '800 20px Arial',
    { "size": 20, "weight": 800, "families": ['arial'] },
    'bolder 20px Arial',
    { "size": 20, "weight": 700, "families": ['arial'] },
    'lighter 20px Arial',
    { "size": 20, "weight": 100, "families": ['arial'] },
    'normal normal normal 16px Impact',
    { "size": 16, "families": ['impact'] },
    'italic small-caps bolder 16px cursive',
    { "size": 16, "style": 1, "variant": 1, "weight": 700, "families": ['cursive'] },
    '20px "new century schoolbook", serif',
    { "size": 20, "families": ['new century schoolbook', 'serif'] },
    '20px "Arial bold 300"', // synthetic case with weight keyword inside family
    { "size": 20, "families": ['Arial bold 300'] },
    "50px \"Helvetica 'Neue'\", \"foo \\\"bar\\\" baz\" , \"Someone's weird \\'edge\\' case\", sans-serif",
    { "size": 50, "families": ["Helvetica 'Neue'", 'foo "bar" baz', "Someone's weird 'edge' case", 'sans-serif'] },
    'Helvetica, sans',
    null,
    '123px thefont/123abc',
    null,
    '123px /\tnormal thefont',
    { "size": 123, "families": ['thefont']},
    '12px/1.2whoops arial',
    null,
    'bold bold 12px thefont',
    null,
    'italic italic 12px Arial',
    null,
    'small-caps bold italic small-caps 12px Arial',
    null,
    'small-caps bold oblique 12px \'A\'ri\\61l',
    { "size": 12, "style": 2, "weight": 700, "variant": 1, "families": ['Arial']},
    '12px/34% "The\\\n Word"',
    { "size": 12, "families": ['The Word']},
    '',
    null,
    'normal normal normal 1%/normal a   ,     \'b\'',
    { "size": 0.1599999964237213, "families": ['a', 'b']},
    'normalnormalnormal 1px/normal a',
    null,
    '12px _the_font',
    { "size": 12, "families": ['_the_font']},
    '9px 7 birds',
    null,
    '2em "Courier',
    null,
    "2em \\'Courier\\",
    { "size": 32, "families": ['\'courier"']},
    '1px \\10abcde',
    { "size": 1, "families": ['${String.fromCharCode(int.parse('10abcd', radix: 16))}e']},
    '3E+2 1e-1px yay',
    { "weight": 300, "size": 0.1, "families": ['yay']}
];

Map mapFromFont(ParsedFont font) {
    return {
        "weight": font.weight,
        "style": font.style,
        "stretch": font.stretch,
        "variant": font.variant,
        "size": font.size,
        "unit": font.unit,
        "family": font.family,
    };
}

bool fontEq(dynamic a, dynamic e) {
    if (e == null && a == null) {
        return true;
    } else if (e == null) {
        return false;
    }
    a = mapFromFont(a);
    for (final prop in e.keys) {
        if (a[prop] is List) {
            if (e[prop] is! List) {
                return false;
            } else if (e[prop].join("@@@@") != a[prop].join("@@@@")) {
                return false;
            }
        } else if (a[prop] != e[prop]) {
            return false;
        }
    }
    return true;
}

var passed = 0;
var failed = 0;

void main() {
    for (var i = 0; i < tests.length; i += 2) {
        final str = tests[i];
        final expected = tests[i+1];
        final actual = parseFontString(str);

        if (expected != null) {
            expected["style"] ??= 0;
            expected["weight"] ??= 400;
            expected["variant"] ??= 0;
        }

        var eq = fontEq(actual, expected);
        if (!eq) {
            print("TEST FAILED (actual, expected)");
            print(actual == null ? null : mapFromFont(actual as ParsedFont));
            print(expected);
            print("");
            failed++;
        } else {
            passed++;
        }
    }

    print("TESTS PASSED: $passed");
    print("TESTS FAILED: $failed");
}