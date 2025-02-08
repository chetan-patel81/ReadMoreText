import 'dart:ui' as ui show TextHeightBehavior;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/string_file.dart';

enum TrimMode { Length, Line }

class Annotation {
  const Annotation({
    required this.regExp,
    required this.spanBuilder,
  });

  final RegExp regExp;
  final TextSpan Function({required String text, required TextStyle textStyle}) spanBuilder;
}

class _TextSpanTrimResult {
  const _TextSpanTrimResult({
    required this.textSpan,
    required this.spanEndIndex,
    required this.didTrim,
  });

  final TextSpan textSpan;
  final int spanEndIndex;
  final bool didTrim;
}

class ReadMoreText extends StatefulWidget {
  final RxBool isCollapsed;
  final int trimLength;
  final int trimLines;
  final TrimMode trimMode;
  final TextStyle? moreStyle;
  final TextStyle? lessStyle;
  final String? preDataText;
  final String? postDataText;
  final TextStyle? preDataTextStyle;
  final TextStyle? postDataTextStyle;
  final TextSpan? richPreData;
  final TextSpan? richPostData;
  final List<Annotation>? annotations;
  final bool isExpandable;
  final String delimiter;
  final String? data;
  final TextSpan? richData;
  final String trimExpandedText;
  final String trimCollapsedText;
  final Color? colorClickableText;
  final TextStyle? delimiterStyle;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final ui.TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  ReadMoreText(
    String this.data, {
    super.key,
    RxBool? isCollapsed,
    this.preDataText,
    this.postDataText,
    this.preDataTextStyle,
    this.postDataTextStyle,
    this.trimExpandedText = StringFile.showLess,
    this.trimCollapsedText = StringFile.readMore,
    this.colorClickableText,
    this.trimLength = 240,
    this.trimLines = 2,
    this.trimMode = TrimMode.Length,
    this.moreStyle,
    this.lessStyle,
    this.delimiter = StringFile.unicodeHorizontalEllipsis,
    this.delimiterStyle,
    this.annotations,
    this.isExpandable = true,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  })  : isCollapsed = isCollapsed ?? false.obs,
        richData = null,
        richPreData = null,
        richPostData = null;

  ReadMoreText.rich(
    TextSpan this.richData, {
    super.key,
    this.richPreData,
    this.richPostData,
    RxBool? isCollapsed,
    this.trimExpandedText = StringFile.showLess,
    this.trimCollapsedText = StringFile.readMore,
    this.colorClickableText,
    this.trimLength = 240,
    this.trimLines = 2,
    this.trimMode = TrimMode.Length,
    this.moreStyle,
    this.lessStyle,
    this.delimiter = StringFile.unicodeHorizontalEllipsis,
    this.delimiterStyle,
    this.isExpandable = true,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  })  : isCollapsed = isCollapsed ?? false.obs,
        data = null,
        annotations = null,
        preDataText = null,
        postDataText = null,
        preDataTextStyle = null,
        postDataTextStyle = null;

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  final TapGestureRecognizer _recognizer = TapGestureRecognizer();
  static final _nonCapturingGroupPattern = RegExp(r'\((?!\?:)');

  @override
  void initState() {
    super.initState();
    _recognizer.onTap = _onTap;
  }

  void _onTap() {
    if (widget.isExpandable) {
      widget.isCollapsed.value = !widget.isCollapsed.value;
    }
  }

  RegExp? _mergeRegexPatterns(List<Annotation>? annotations) {
    if (annotations == null || annotations.isEmpty) {
      return null;
    } else if (annotations.length == 1) {
      return annotations[0].regExp;
    }

    return RegExp(
      annotations.map((a) => '(${a.regExp.pattern.replaceAll(_nonCapturingGroupPattern, '(?:')})').join('|'),
    );
  }

  @override
  void dispose() {
    _recognizer.dispose();
    widget.isCollapsed.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final defaultTextStyle = DefaultTextStyle.of(context);
      TextStyle effectiveTextStyle;
      if (widget.style == null || widget.style!.inherit) {
        effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
      } else {
        effectiveTextStyle = widget.style!;
      }
      if (MediaQuery.boldTextOf(context)) {
        effectiveTextStyle = effectiveTextStyle.merge(const TextStyle(fontWeight: FontWeight.bold));
      }
      final registrar = SelectionContainer.maybeOf(context);

      final textScaler = widget.textScaler ?? MediaQuery.textScalerOf(context);

      final textAlign = widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
      final textDirection = widget.textDirection ?? Directionality.of(context);
      final locale = widget.locale ?? Localizations.maybeLocaleOf(context);
      final softWrap = widget.softWrap ?? defaultTextStyle.softWrap;
      final overflow = widget.overflow ?? defaultTextStyle.overflow;
      final textWidthBasis = widget.textWidthBasis ?? defaultTextStyle.textWidthBasis;
      final textHeightBehavior =
          widget.textHeightBehavior ?? defaultTextStyle.textHeightBehavior ?? DefaultTextHeightBehavior.maybeOf(context);
      final selectionColor =
          widget.selectionColor ?? DefaultSelectionStyle.of(context).selectionColor ?? DefaultSelectionStyle.defaultColor;

      final colorClickableText = widget.colorClickableText ?? Theme.of(context).colorScheme.secondary;
      final defaultLessStyle = widget.lessStyle ?? effectiveTextStyle.copyWith(color: colorClickableText);
      final defaultMoreStyle = widget.moreStyle ?? effectiveTextStyle.copyWith(color: colorClickableText);
      final defaultDelimiterStyle = widget.delimiterStyle ?? effectiveTextStyle;

      final link = TextSpan(
        text: widget.isCollapsed.value ? widget.trimCollapsedText : widget.trimExpandedText,
        style: widget.isCollapsed.value ? defaultMoreStyle : defaultLessStyle,
        recognizer: _recognizer,
      );
      final delimiter = TextSpan(
        text: widget.isCollapsed.value
            ? widget.trimCollapsedText.isNotEmpty
                ? widget.delimiter
                : ''
            : '',
        style: defaultDelimiterStyle,
        recognizer: _recognizer,
      );

      Widget result = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          assert(constraints.hasBoundedWidth);
          final maxWidth = constraints.maxWidth;

          TextSpan? preTextSpan;
          TextSpan? postTextSpan;

          if (widget.richPreData != null) {
            preTextSpan = widget.richPreData;
          } else if (widget.preDataText != null) {
            preTextSpan = TextSpan(
              text: '${widget.preDataText!} ',
              style: widget.preDataTextStyle ?? effectiveTextStyle,
            );
          }

          if (widget.richPostData != null) {
            postTextSpan = widget.richPostData;
          } else if (widget.postDataText != null) {
            postTextSpan = TextSpan(
              text: ' ${widget.postDataText!}',
              style: widget.postDataTextStyle ?? effectiveTextStyle,
            );
          }

          final TextSpan dataTextSpan;

          if (widget.richData != null) {
            assert(_isTextSpan(widget.richData!));
            dataTextSpan = TextSpan(
              style: effectiveTextStyle,
              children: [widget.richData!],
            );

          } else {
            dataTextSpan = _buildAnnotatedTextSpan(
              data: widget.data!,
              textStyle: effectiveTextStyle,
              regExp: _mergeRegexPatterns(widget.annotations),
              annotations: widget.annotations,
            );
          }


          final text = TextSpan(
            children: [
              if (preTextSpan != null) preTextSpan,
              dataTextSpan,
              if (postTextSpan != null) postTextSpan,
            ],
          );


          final textPainter = TextPainter(
            text: link,
            textAlign: textAlign,
            textDirection: textDirection,
            locale: locale,
            textScaler: textScaler,
            maxLines: widget.trimLines,
            strutStyle: widget.strutStyle,
            textWidthBasis: textWidthBasis,
            textHeightBehavior: textHeightBehavior,
            ellipsis: widget.overflow == TextOverflow.ellipsis ? widget.delimiter : null,
          );
          textPainter.layout(maxWidth: maxWidth);
          final linkSize = textPainter.size;


          textPainter.text = delimiter;
          textPainter.layout(maxWidth: maxWidth);
          final delimiterSize = textPainter.size;


          textPainter.text = text;
          textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
          final textSize = textPainter.size;


          var linkLongerThanLine = false;
          int endIndex;

          if (linkSize.width < maxWidth) {
            final readMoreSize = linkSize.width + delimiterSize.width;
            final pos = textPainter.getPositionForOffset(
              Offset(
                widget.textDirection == TextDirection.rtl ? readMoreSize : textSize.width - readMoreSize,
                textSize.height,
              ),
            );
            endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
          } else {
            final pos = textPainter.getPositionForOffset(
              textSize.bottomLeft(Offset.zero),
            );
            endIndex = pos.offset;
            linkLongerThanLine = true;
          }

          late final TextSpan textSpan;
          switch (widget.trimMode) {
            case TrimMode.Length:
              if (widget.richData != null) {
                final trimResult = _trimTextSpan(
                  textSpan: dataTextSpan,
                  spanStartIndex: 0,
                  endIndex: widget.trimLength,
                  splitByRunes: true,
                );

                if (trimResult.didTrim) {
                  textSpan = TextSpan(
                    children: [
                      if (widget.isCollapsed.value) trimResult.textSpan else dataTextSpan,
                      delimiter,
                      link,
                    ],
                  );
                } else {
                  textSpan = dataTextSpan;
                }
              } else {
                if (widget.trimLength < widget.data!.runes.length) {
                  final effectiveDataTextSpan = widget.isCollapsed.value
                      ? _trimTextSpan(
                          textSpan: dataTextSpan,
                          spanStartIndex: 0,
                          endIndex: widget.trimLength,
                          splitByRunes: true,
                        ).textSpan
                      : dataTextSpan;

                  textSpan = TextSpan(
                    children: <TextSpan>[
                      effectiveDataTextSpan,
                      delimiter,
                      link,
                    ],
                  );
                } else {
                  textSpan = dataTextSpan;
                }
              }
              break;
            case TrimMode.Line:
              if (textPainter.didExceedMaxLines) {
                final effectiveDataTextSpan = widget.isCollapsed.value
                    ? _trimTextSpan(
                        textSpan: dataTextSpan,
                        spanStartIndex: 0,
                        endIndex: endIndex,
                        splitByRunes: false,
                      ).textSpan
                    : dataTextSpan;

                textSpan = TextSpan(
                  children: <TextSpan>[
                    effectiveDataTextSpan,
                    if (linkLongerThanLine) const TextSpan(text: StringFile.unicodeLineSeparator),
                    delimiter,
                    link,
                  ],
                );
              } else {
                textSpan = dataTextSpan;
              }
              break;
          }

          return RichText(
            text: TextSpan(
              children: [
                if (preTextSpan != null) preTextSpan,
                textSpan,
                if (postTextSpan != null) postTextSpan,
              ],
            ),
            textAlign: textAlign,
            textDirection: textDirection,
            locale: locale,
            softWrap: softWrap,
            overflow: overflow,
            textScaler: textScaler,
            strutStyle: widget.strutStyle,
            textWidthBasis: textWidthBasis,
            textHeightBehavior: textHeightBehavior,
            selectionRegistrar: registrar,
            selectionColor: selectionColor,
          );
        },
      );
      if (registrar != null) {
        result = MouseRegion(
          cursor: DefaultSelectionStyle.of(context).mouseCursor ?? SystemMouseCursors.text,
          child: result,
        );
      }
      if (widget.semanticsLabel != null) {
        result = Semantics(
          textDirection: widget.textDirection,
          label: widget.semanticsLabel,
          child: ExcludeSemantics(
            child: result,
          ),
        );
      }
      return result;
    });
  }

  TextSpan _buildAnnotatedTextSpan({
    required String data,
    required TextStyle textStyle,
    required RegExp? regExp,
    required List<Annotation>? annotations,
  }) {
    if (regExp == null || data.isEmpty) {
      return TextSpan(text: data, style: textStyle);
    }

    final contents = <TextSpan>[];

    data.splitMapJoin(
      regExp,
      onMatch: (Match regexMatch) {
        final matchedText = regexMatch.group(0)!;
        late final Annotation matchedAnnotation;

        if (annotations!.length == 1) {
          matchedAnnotation = annotations[0];
        } else {
          for (var i = 0; i < regexMatch.groupCount; i++) {
            if (matchedText == regexMatch.group(i + 1)) {
              matchedAnnotation = annotations[i];
              break;
            }
          }
        }

        final content = matchedAnnotation.spanBuilder(
          text: matchedText,
          textStyle: textStyle,
        );

        assert(_isTextSpan(content));
        contents.add(content);

        return '';
      },
      onNonMatch: (String unmatchedText) {
        contents.add(TextSpan(text: unmatchedText));
        return '';
      },
    );

    return TextSpan(style: textStyle, children: contents);
  }

  _TextSpanTrimResult _trimTextSpan({
    required TextSpan textSpan,
    required int spanStartIndex,
    required int endIndex,
    required bool splitByRunes,
  }) {
    var spanEndIndex = spanStartIndex;

    final text = textSpan.text;
    if (text != null) {
      final textLen = splitByRunes ? text.runes.length : text.length;
      spanEndIndex += textLen;

      if (spanEndIndex >= endIndex) {
        final newText = splitByRunes
            ? String.fromCharCodes(text.runes, 0, endIndex - spanStartIndex)
            : text.substring(0, endIndex - spanStartIndex);

        final nextSpan = TextSpan(
          text: newText,
          children: null,

          style: textSpan.style,
          recognizer: textSpan.recognizer,
          mouseCursor: textSpan.mouseCursor,
          onEnter: textSpan.onEnter,
          onExit: textSpan.onExit,
          semanticsLabel: textSpan.semanticsLabel,
          locale: textSpan.locale,
          spellOut: textSpan.spellOut,
        );

        return _TextSpanTrimResult(
          textSpan: nextSpan,
          spanEndIndex: spanEndIndex,
          didTrim: true,
        );
      }
    }

    var didTrim = false;
    final newChildren = <InlineSpan>[];

    final children = textSpan.children;
    if (children != null) {
      for (final child in children) {
        if (child is TextSpan) {
          final result = _trimTextSpan(
            textSpan: child,
            spanStartIndex: spanEndIndex,
            endIndex: endIndex,
            splitByRunes: splitByRunes,
          );

          spanEndIndex = result.spanEndIndex;
          newChildren.add(result.textSpan);

          if (result.didTrim) {
            didTrim = true;
            break;
          }
        } else {

          newChildren.add(child);
        }
      }
    }

    final resultTextSpan = didTrim
        ? TextSpan(
            text: textSpan.text,
            children: newChildren,
            style: textSpan.style,
            recognizer: textSpan.recognizer,
            mouseCursor: textSpan.mouseCursor,
            onEnter: textSpan.onEnter,
            onExit: textSpan.onExit,
            semanticsLabel: textSpan.semanticsLabel,
            locale: textSpan.locale,
            spellOut: textSpan.spellOut,
          )
        : textSpan;

    return _TextSpanTrimResult(
      textSpan: resultTextSpan,
      spanEndIndex: spanEndIndex,
      didTrim: didTrim,
    );
  }

  bool _isTextSpan(InlineSpan span) {
    if (span is! TextSpan) {
      return false;
    }

    final children = span.children;
    if (children == null || children.isEmpty) {
      return true;
    }

    return children.every(_isTextSpan);
  }
}
