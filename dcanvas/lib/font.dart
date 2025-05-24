class TextMetrics {
    double width;
    double actualBoundingBoxLeft;
    double actualBoundingBoxRight;
    double actualBoundingBoxAscent;
    double actualBoundingBoxDescent;
    double emHeightAscent;
    double emHeightDescent;
    double alphabeticBaseline;
    TextMetrics({
        required this.width,
        required this.actualBoundingBoxLeft,
        required this.actualBoundingBoxRight,
        required this.actualBoundingBoxAscent,
        required this.actualBoundingBoxDescent,
        required this.emHeightAscent,
        required this.emHeightDescent,
        required this.alphabeticBaseline,
    });
}

// based on https://github.com/jednano/parse-css-font/
String unquote(String str) {
	var reg = RegExp("[\'\\\"]");
	if (str.isEmpty) {
		return '';
	}
	if (reg.hasMatch(str[0])) {
		str = str.substring(1);
	}
	if (reg.hasMatch(str[str.length - 1])) {
		str = str.substring(0, str.length - 1);
	}
	return str;
}

const fontWeightKeywords = [
	"normal",
	"bold",
	"bolder",
	"lighter",
	"100",
	"200",
	"300",
	"400",
	"500",
	"600",
	"700",
	"800",
	"900"
];
int fontWeightFromString(String weight) {
    switch (weight) {
        case "normal":
            return 400;
        case "bold":
            return 700;
        case "bolder":
            return 700;
        case "lighter":
            return 300;
        default:
            var numbers = "";
            for (var i = 0; i < weight.length; i++) {
                final chCode = weight.codeUnitAt(i);
                if (chCode >= 48 && chCode <= 57) {
                    numbers += weight[i];
                }
            }
            return int.parse(numbers);
    }
}

const fontStyleKeywords = [
	"normal",
	"italic",
	"oblique"
];
const fontStretchKeywords = [
	"normal",
	"condensed",
	"semi-condensed",
	"extra-condensed",
	"ultra-condensed",
	"expanded",
	"semi-expanded",
	"extra-expanded",
	"ultra-expanded"
];

class cssListHelpers {
	/**
	 * Splits a CSS declaration value (shorthand) using provided separators
	 * as the delimiters.
	 */
	static List<String> split(
		/**
		 * A CSS declaration value (shorthand).
		 */
		String value,
		/**
		 * Any number of separator characters used for splitting.
		 */
		List<String> separators,
		[bool last=false]
	) {
		List<String> array = [];
		var current = '';
		var splitMe = false;

		var func = 0;
		String quote /* '"' | '\'' | false */ = "";
		var escape  = false;

		for (var i = 0; i < value.length; i++) {
            final char = value[i];
			if (quote.isNotEmpty) {
				if (escape) {
					escape = false;
				} else if (char == '\\') {
					escape = true;
				} else if (char == quote) {
					quote = "";
				}
			} else if (char == '"' || char == '\'') {
				quote = char;
			} else if (char == '(') {
				func += 1;
			} else if (char == ')') {
				if (func > 0) {
					func -= 1;
				}
			} else if (func == 0) {
				if (separators.contains(char)) {
					splitMe = true;
				}
			}

			if (splitMe) {
				if (current != '') {
					array.add(current.trim());
				}
				current = '';
				splitMe = false;
			} else {
				current += char;
			}
		}

		if (last || current != '') {
			array.add(current.trim());
		}
		return array;
	}

	/**
	 * Splits a CSS declaration value (shorthand) using whitespace characters
	 * as the delimiters.
	 */
	static List<String> splitBySpaces(
		/**
		 * A CSS declaration value (shorthand).
		 */
		String value,
	) {
		const spaces = [' ', '\n', '\t'];
		return cssListHelpers.split(value, spaces);
	}

	/**
	 * Splits a CSS declaration value (shorthand) using commas as the delimiters.
	 */
	static List<String> splitByCommas(
		/**
		 * A CSS declaration value (shorthand).
		 */
		String value,
	) {
		const comma = ',';
		return cssListHelpers.split(value, [comma], true);
	}
}

const cssFontSizeKeywords = [
	"xx-small",
	"x-small",
	"small",
	"medium",
	"large",
	"x-large",
	"xx-large",
	"larger",
	"smaller"
];

bool isSize(String value) {
	return RegExp(r'^[\d\.]').hasMatch(value)
		|| value.contains('/')
		|| cssFontSizeKeywords.contains(value);
}

class ParsedFont {
    int weight;
    String style;
    String stretch;
    String variant;
    double size;
    String unit;
    String family;

    ParsedFont({
        required this.weight,
        required this.style,
        required this.stretch,
        required this.variant,
        required this.size,
        required this.unit,
        required this.family,
    });
}

const errorPrefix = '[parse-css-font]';

const firstDeclarations = [
	'style',
	'weight',
	'stretch',
	'variant',
];

ParsedFont? parseFontString(String value) {
	if (value == '') {
		return null;
	}

	final font = ParsedFont(
		size: 16,
		stretch: '',
		style: '',
		variant: '',
		weight: 0,
        unit: 'px',
        family: ''
    );

    String? style(String token) {
		if (!fontStyleKeywords.contains(token)) {
			return null;
		}
		if (font.style.isNotEmpty) {
			throw 'Font style already defined.';
		}
		return (font.style = token);
	}

	int? weight(String token) {
		if (!fontWeightKeywords.contains(token)) {
			return null;
		}
		if (font.weight != 0) {
			throw 'Font weight already defined.';
		}
		return font.weight = fontWeightFromString(token);
	}

	String? stretch(String token) {
		if (!fontStretchKeywords.contains(token)) {
			return null;
		}
		if (font.stretch.isNotEmpty) {
			throw 'Font stretch already defined.';
		}
		return (font.stretch = token);
	}

	String? variant(String token) {
        if (!isSize(token)) {
            return font.variant.isNotEmpty ? [font.variant, token].join(' ') : token;
        }
		return null;
	}

	final consumers = [style, weight, stretch, variant];
	final tokens = cssListHelpers.splitBySpaces(value);
	nextToken: for (
		var token = tokens.removeAt(0);
		tokens.isNotEmpty;
		token = tokens.removeAt(0)
	) {
		if (token == 'normal') {
			continue;
		}

		for (final consume in consumers) {
            try {
                final value = consume(token);
                if (value != null && ((value is String && value.isNotEmpty) || (value is int && value != 0))) {
                    continue nextToken;
                }
            } catch (e) {
                return null;
            }
		}

		final parts = cssListHelpers.split(token, ['/']);
		font.size = fontWeightFromString(parts[0]).toDouble();
		if (parts.length > 1 && parts[1].isNotEmpty) {
			// font.lineHeight = double.parse(parts[1]);
		} else if (tokens[0] == '/') {
			tokens.removeAt(0);
			// font.lineHeight = double.parse(tokens.removeAt(0));
		}
		if (tokens.isEmpty) {
			// Missing required font-family
            return null;
		}
		font.family = cssListHelpers.splitByCommas(tokens.join(' ')).map(unquote).join(" ");

        if (font.style.isEmpty) font.style = "normal";
        if (font.weight == 0) font.weight = 400;
        if (font.stretch.isEmpty) font.stretch = "normal";
        if (font.variant.isEmpty) font.variant = "normal";

		return font;
	}

	// Missing required font-size
    return null;
}
