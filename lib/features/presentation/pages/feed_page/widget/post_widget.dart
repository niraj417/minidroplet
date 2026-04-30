import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tinydroplets/common/widgets/custom_image.dart';
import 'package:tinydroplets/core/theme/app_color.dart';
import 'package:tinydroplets/features/presentation/pages/video_player/post_video_player.dart';

class PostWidget extends StatefulWidget {
  final String avatarUrl;
  final String companyName;
  final String shareDate;
  final String userName;
  final String text;
  final String imageUrl;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onDoubleTap;
  final String likeCount;
  final String commentCount;
  final String type;

  const PostWidget({
    super.key,
    required this.avatarUrl,
    required this.companyName,
    required this.shareDate,
    required this.userName,
    required this.text,
    required this.imageUrl,
    required this.isLiked,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.likeCount,
    required this.commentCount,
    required this.onDoubleTap,
    required this.type,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _showLike = false;
  bool isTextExpanded = false;
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likeCount = int.tryParse(widget.likeCount) ?? 0;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showLike = false);
        _controller.reset();
      }
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : (_likeCount > 0 ? _likeCount - 1 : 0);
      _showLike = true;
    });
    _controller.forward();
    widget.onLike();
  }

  void _doubleTapLike() {
    setState(() {
      if (!_isLiked) {
        _isLiked = true;
        _likeCount = _likeCount + 1;
      }
      _showLike = true;
    });
    _controller.forward();
    widget.onDoubleTap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// limits: keeps post card bounded so GPU won't attempt giant layout
  @override
  Widget build(BuildContext context) {
    // Card max width for large screens (optional)
    final maxCardWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxCardWidth),
        child: Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          elevation: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(AppColor.primaryColor), width: 1),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        height: 36,
                        width: 36,
                        clipBehavior: Clip.hardEdge,
                        child: CustomImage(imageUrl: widget.avatarUrl, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.companyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(widget.shareDate, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 6),
                              const Text('•', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 6),
                              Flexible(child: Text(widget.userName, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // optional menu
                    // Icon(Icons.more_horiz),
                  ],
                ),
              ),

              // Body: safe expandable text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SafeExpandableText(
                  text: widget.text,
                  initiallyExpanded: isTextExpanded,
                  onToggle: (v) => setState(() => isTextExpanded = v),
                  maxLines: 5, // show 5 lines initially
                ),
              ),

              const SizedBox(height: 8),

              // Media section (image or video) - constrained and lazily sized
              if (widget.imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 420, // caps memory use; adjust as necessary
                      minHeight: 0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onDoubleTap: _doubleTapLike,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Use a fixed aspect ratio so image/video gets proper constraints
                            if (widget.type == 'image')
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: CustomImage(
                                  imageUrl: widget.imageUrl,
                                  fit: BoxFit.cover,
                                  //height: double.infinity,
                                  //width: double.infinity,
                                  //width: double.maxFinite,
                                ),
                              )
                            else
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: VideoPlayerWidget(
                                  videoUrl: widget.imageUrl,
                                  fullScreen: false,
                                ),
                              ),
                            if (_showLike)
                              AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _opacityAnimation.value,
                                    child: Transform.scale(scale: _scaleAnimation.value, child: child),
                                  );
                                },
                                child: const Icon(Icons.favorite, color: Colors.red, size: 86),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$_likeCount Likes', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    const Text('•'),
                    const SizedBox(width: 8),
                    Text('${widget.commentCount} comments', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),

              // Divider + actions
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      color: _isLiked ? Colors.red : null,
                      onPressed: _toggleLike,
                      icon: _isLiked ? const Icon(CupertinoIcons.heart_fill) : const Icon(CupertinoIcons.heart),
                      tooltip: 'Like',
                    ),
                    IconButton(
                      onPressed: widget.onComment,
                      icon: const Icon(CupertinoIcons.chat_bubble),
                      tooltip: 'Comment',
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: widget.onShare,
                      icon: const Icon(CupertinoIcons.share),
                      tooltip: 'Share',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lightweight safe expandable text that truncates initial lines and only builds full layout when expanded.
/// This avoids letting Flutter try to layout hundreds of lines at once on first build.
class SafeExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onToggle;

  const SafeExpandableText({
    super.key,
    required this.text,
    this.maxLines = 4,
    this.initiallyExpanded = false,
    this.onToggle,
  });

  @override
  State<SafeExpandableText> createState() => _SafeExpandableTextState();
}

class _SafeExpandableTextState extends State<SafeExpandableText> {
  late bool _expanded;
  bool _isOverflowing = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder used to check overflow with a TextPainter without forcing full layout.
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;

      // measure if text will overflow maxLines
      final tp = TextPainter(
        text: TextSpan(text: widget.text, style: DefaultTextStyle.of(context).style),
        textDirection: TextDirection.ltr,
        maxLines: widget.maxLines,
      )..layout(maxWidth: maxWidth);

      _isOverflowing = tp.didExceedMaxLines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: ConstrainedBox(
              constraints: _expanded
                  ? const BoxConstraints() // no constraint when expanded (let it grow inside list item but external list will lazy build)
                  : BoxConstraints(maxHeight: tp.height), // match measured height; prevents expensive layout
              child: Text(
                widget.text,
                softWrap: true,
                overflow: TextOverflow.fade,
                maxLines: _expanded ? null : widget.maxLines,
                style: const TextStyle(fontSize: 14, height: 1.3),
              ),
            ),
          ),
          if (_isOverflowing)
            GestureDetector(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                  widget.onToggle?.call(_expanded);
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  _expanded ? 'Show less' : 'Read more',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13),
                ),
              ),
            ),
        ],
      );
    });
  }
}
