import 'package:linkify/linkify.dart';

final _emailRegex = RegExp(
  r'^(.*?)((mailto:)?[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z][A-Z]+)',
  caseSensitive: false,
  dotAll: true,
);

class EmailLinkifier extends Linkifier {
  const EmailLinkifier();

  @override
  Future<List<LinkifyElement>> parse(elements, options) async {
    final list = <LinkifyElement>[];

    await Future.forEach(elements, (element) async {
      if (element is TextElement) {
        final match = _emailRegex.firstMatch(element.text);

        if (match == null) {
          list.add(element);
        } else {
          final text = element.text.replaceFirst(match.group(0)!, '');

          if (match.group(1)?.isNotEmpty == true) {
            list.add(TextElement(match.group(1)!));
          }

          if (match.group(2)?.isNotEmpty == true) {
            // Always humanize emails
            list.add(EmailElement(
              match.group(2)!.replaceFirst(RegExp(r'mailto:'), ''),
            ));
          }

          if (text.isNotEmpty) {
            list.addAll(await parse([TextElement(text)], options));
          }
        }
      } else if (element is LinkifyElement) {
        list.add(element);
      }
    });

    return list;
  }
}

/// Represents an element containing an email address
class EmailElement extends LinkableElement {
  final String emailAddress;

  EmailElement(this.emailAddress) : super(emailAddress, 'mailto:$emailAddress');

  @override
  String toString() {
    return "EmailElement: '$emailAddress' ($text)";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  bool equals(other) => other is EmailElement && super.equals(other) && other.emailAddress == emailAddress;
}
