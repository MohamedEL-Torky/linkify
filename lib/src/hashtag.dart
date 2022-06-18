import 'package:linkify/linkify.dart';

/// For details on how this RegEx works, go to this link.
/// https://regex101.com/r/QN046t/1
final _userMentionRegex = RegExp(
  r'(.*?)(?<![^\s#])#([^\s#]+(?:[.!][^\s#]+)*)',
  caseSensitive: false,
  dotAll: true,
);

class HashTagLinkifier extends Linkifier {
  HashTagLinkifier();
  int index = 0;

  @override
  Future<List<LinkifyElement>> parse(elements, options) async {
    final list = <LinkifyElement>[];
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
            list.add(HashTagElement('#${match.group(2)!}', index));
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

class HashTagElement extends LinkableElement {
  final String hashTag;
  final int index;

  HashTagElement(this.hashTag, this.index) : super(hashTag, hashTag);

  @override
  String toString() {
    return "HashTagElement: '$hashTag' ($text)";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  bool equals(other) => other is HashTagElement && super.equals(other) && other.hashTag == hashTag;

  @override
  int get hashCode => hashTag.hashCode;
}
