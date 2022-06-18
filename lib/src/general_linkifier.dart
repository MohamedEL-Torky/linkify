import 'package:linkify/linkify.dart';

/// For details on how this RegEx works, go to this link.
/// https://regex101.com/r/QN046t/1
final _hashTagRegex = RegExp(
  r'(?<![^\s#])#([^\s#]+(?:[.!][^\s#]+)*)',
  caseSensitive: false,
  dotAll: true,
);
final _userMentionRegex = RegExp(
  r'(?<![^\s@])@([^\s#]+(?:[.!][^\s@]+)*)',
  caseSensitive: false,
  dotAll: true,
);

class GeneralLinkifier extends Linkifier {
  const GeneralLinkifier();

  @override
  Future<List<LinkifyElement>> parse(elements, options) async {
    final list = elements;
    var hashTagMentionIndex = 0;
    var userMentionIndex = 0;

    await Future.forEach(elements, (element) async {
      if (element is TextElement) {
        final hashTagMatch = _hashTagRegex.firstMatch(element.text);
        final userMentionMatch = _userMentionRegex.firstMatch(element.text);

        if (hashTagMatch != null) {
          final text = element.text.replaceFirst(hashTagMatch.group(0)!, '');

          if (hashTagMatch.group(1)?.isNotEmpty == true) {
            list.add(TextElement(hashTagMatch.group(1)!));
          }

          if (hashTagMatch.group(2)?.isNotEmpty == true) {
            list.add(HashTagElement('#${hashTagMatch.group(2)!}', hashTagMentionIndex));
            hashTagMentionIndex++;
          }

          if (text.isNotEmpty) {
            list.addAll(await parse([TextElement(text)], options));
          }
        } else if (userMentionMatch != null) {
          final text = element.text.replaceFirst(userMentionMatch.group(0)!, '');

          if (userMentionMatch.group(1)?.isNotEmpty == true) {
            list.add(TextElement(userMentionMatch.group(1)!));
          }

          if (userMentionMatch.group(2)?.isNotEmpty == true) {
            list.add(UserMentionElement(userMentionMatch.group(2)!, userMentionIndex));
            userMentionIndex++;
          }

          if (text.isNotEmpty) {
            list.addAll(await parse([TextElement(text)], options));
          }
        } else {
          list.add(element);
        }
      } else if (element is LinkifyElement) {
        list.add(element);
      }
    });

    return list;
  }
}

/// Represents an element containing an HashTag
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
