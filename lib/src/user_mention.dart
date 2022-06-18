import 'package:linkify/linkify.dart';

/// For details on how this RegEx works, go to this link.
/// https://regex101.com/r/QN046t/1
final _userMentionRegex = RegExp(
  r'(.*?)(?<![^\s@])@([^\s#]+(?:[.!][^\s@]+)*)',
  caseSensitive: false,
  dotAll: true,
);

class UserMentionLinkifier extends Linkifier {
  const UserMentionLinkifier();

  @override
  Future<List<LinkifyElement>> parse(elements, options) async {
    final list = <LinkifyElement>[];
    var index = 0;
    await Future.forEach(elements, (element) async {
      if (element is TextElement) {
        final match = _userMentionRegex.firstMatch(element.text);

        if (match == null) {
          list.add(element);
        } else {
          final text = element.text.replaceFirst(match.group(0)!, '');

          if (match.group(1)?.isNotEmpty == true) {
            list.add(TextElement(match.group(1)!));
          }

          if (match.group(2)?.isNotEmpty == true) {
            list.add(UserMentionElement(match.group(2)!, index));
            index++;
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

/// Represents an element containing an user tag
class UserMentionElement extends LinkableElement {
  final String mention;
  final int index;

  UserMentionElement(this.mention, this.index) : super(mention, mention);

  @override
  String toString() {
    return "UserMentionElement: '$mention' ($text)";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  bool equals(other) => other is UserMentionElement && super.equals(other) && other.mention == mention;

  @override
  int get hashCode => mention.hashCode;
}
