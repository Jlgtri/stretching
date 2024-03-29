import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/hooks/hook_consumer_stateful_widget.dart';
import 'package:stretching/providers/hide_appbar_provider.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The paragraph model for the [ContentScreen].
@immutable
class ContentParagraph {
  /// The paragraph model for the [ContentScreen].
  const ContentParagraph({
    required final this.body,
    final this.title = '',
    final this.expandable = true,
  });

  /// The title of this paragraph.
  final String title;

  /// The body of this paragraph.
  final String body;

  /// If the [body] can be expanded.
  final bool expandable;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is ContentParagraph &&
          other.title == title &&
          other.body == body &&
          other.expandable == expandable;

  @override
  int get hashCode => title.hashCode ^ body.hashCode ^ expandable.hashCode;

  @override
  String toString() => 'ContentParagraph(title: $title, body: $body, '
      'expandable: $expandable)';
}

/// The screen that shows a content on a similar template.
class ContentScreen extends HookConsumerStatefulWidget {
  /// The screen that shows a content on a similar template.
  const ContentScreen({
    required final this.type,
    required final this.title,
    required final this.carousel,
    final this.children = const Iterable<Widget>.empty(),
    final this.carouselHeight = 240,
    final this.subtitle = '',
    final this.secondSubtitle = '',
    final this.trailing,
    final this.persistentFooterButtons = const Iterable<Widget>.empty(),
    final this.bottomNavigationBar,
    final this.paragraphs = const Iterable<ContentParagraph>.empty(),
    final this.onBackButtonPressed,
    final Key? key,
  })  : assert(title != '', 'Title can not be empty.'),
        super(key: key);

  /// The type of this navigation screen.
  final NavigationScreen? type;

  /// The title of this screen.
  final String title;

  /// The carousel to use in this screen.
  ///
  /// If it is a [CarouselSlider], it is automatically added an indicator.
  final Widget carousel;

  /// The extra children for this screen.
  final Iterable<Widget> children;

  /// The height of the [carousel].
  final double carouselHeight;

  /// The subtitle of this screen.
  final String subtitle;

  /// The second subtitle of this screen.
  final String secondSubtitle;

  /// The action to put on the right side of the heading.
  final Widget? trailing;

  /// The widgets at the bottom of this screen.
  final Iterable<Widget> persistentFooterButtons;

  /// The bottom navigation bar of this screen.
  final Widget? bottomNavigationBar;

  /// The children to put on this screen.
  final Iterable<ContentParagraph> paragraphs;

  /// The callback on press of the back button.
  final void Function()? onBackButtonPressed;

  @override
  ContentScreenState createState() => ContentScreenState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(EnumProperty<NavigationScreen>('type', type))
        ..add(StringProperty('title', title))
        ..add(DiagnosticsProperty<Widget>('carousel', carousel))
        ..add(IterableProperty<Widget>('children', children))
        ..add(DoubleProperty('carouselHeight', carouselHeight))
        ..add(StringProperty('subtitle', subtitle))
        ..add(StringProperty('secondSubtitle', secondSubtitle))
        ..add(DiagnosticsProperty<Widget?>('trailing', trailing))
        ..add(
          IterableProperty<Widget>(
            'persistentFooterButtons',
            persistentFooterButtons,
          ),
        )
        ..add(IterableProperty<ContentParagraph>('paragraphs', paragraphs))
        ..add(
          ObjectFlagProperty<void Function()>.has(
            'onBackButtonPressed',
            onBackButtonPressed,
          ),
        ),
    );
  }
}

/// The state of the [ContentScreen] that supportes routing.
class ContentScreenState extends ConsumerState<ContentScreen>
    with HideAppBarRouteAware {
  @override
  NavigationScreen? get screenType => widget.type;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: widget.persistentFooterButtons.isNotEmpty
            ? NavigationRoot.navBarHeight
            : NavigationRoot.navBarHeight - 15,
      ),
      child: Scaffold(
        bottomNavigationBar: widget.bottomNavigationBar,
        persistentFooterButtons:
            widget.persistentFooterButtons.toList(growable: false),
        body: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: <Widget>[
            /// Carousel with indicator and actions
            SliverAppBar(
              pinned: true,
              expandedHeight: widget.carouselHeight,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: theme.colorScheme.onSurface.withOpacity(1 / 5),
              ),
              leading: FontIconBackButton(
                onPressed: widget.onBackButtonPressed,
              ),
              // actions: <Widget>[
              //   FontIconButton(
              //     FontIcon(
              //       FontIconData(
              //         IconsCG.share,
              //         color: appBarTheme.foregroundColor,
              //         height: 28,
              //         width: 28,
              //       ),
              //     ),
              //     tooltip: TR.tooltipsShare.tr(),
              //     // onPressed: () => Share.share(),
              //   )
              // ],
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: widget.carousel is CarouselSlider
                    ? _ContentCarousel(widget.carousel as CarouselSlider)
                    : widget.carousel,
              ),
            ),

            /// Main Content
            SliverPadding(
              padding: const EdgeInsets.all(16).copyWith(bottom: 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    /// Heading with trailing action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.title,
                                style: widget.secondSubtitle.isNotEmpty
                                    ? theme.textTheme.headline1
                                    : theme.textTheme.headline2,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor:
                                    mediaQuery.textScaleFactor.clamp(0, 1.2),
                              ),
                              Flexible(
                                child: Text(
                                  widget.subtitle,
                                  style: theme.textTheme.bodyText2,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.secondSubtitle.isNotEmpty)
                                Text(
                                  widget.secondSubtitle,
                                  style: theme.textTheme.bodyText2
                                      ?.copyWith(color: theme.hintColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        if (widget.trailing != null) widget.trailing!,
                      ],
                    ),

                    /// Extra content
                    ...widget.children,

                    /// Main Content
                    for (final paragraph in widget.paragraphs)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (paragraph.title.isNotEmpty) ...<Widget>[
                              Text(
                                paragraph.title,
                                style: theme.textTheme.headline3,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 14),
                            ],
                            Flexible(
                              child: ExpandableText(
                                paragraph.body,
                                expanded: !paragraph.expandable,
                                expandText: TR.miscExtend.tr(),
                                maxLines: 4,
                                linkColor: theme.hintColor,
                                linkEllipsis: false,
                                animation: true,
                                animationCurve: Curves.easeOut,
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                style: theme.textTheme.bodyText2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.paragraphs.isNotEmpty)
                      const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentCarousel extends HookWidget {
  const _ContentCarousel(final this.carousel, {final Key? key})
      : super(key: key);

  final CarouselSlider carousel;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final currentCarouselIndex = useState<int>(0);
    final controller =
        useMemoized(() => this.carousel.createState().carouselController);
    final carousel = useMemoized(() {
      final options = CarouselOptions(
        height: this.carousel.options.height,
        aspectRatio: this.carousel.options.aspectRatio,
        viewportFraction: this.carousel.options.viewportFraction,
        initialPage: this.carousel.options.initialPage,
        enableInfiniteScroll: this.carousel.options.enableInfiniteScroll,
        reverse: this.carousel.options.reverse,
        autoPlay: this.carousel.options.autoPlay,
        autoPlayInterval: this.carousel.options.autoPlayInterval,
        autoPlayAnimationDuration:
            this.carousel.options.autoPlayAnimationDuration,
        autoPlayCurve: this.carousel.options.autoPlayCurve,
        enlargeCenterPage: this.carousel.options.enlargeCenterPage,
        scrollDirection: this.carousel.options.scrollDirection,
        onPageChanged: (final index, final reason) async {
          currentCarouselIndex.value = index;
          await this.carousel.options.onPageChanged?.call(index, reason);
        },
        onScrolled: this.carousel.options.onScrolled,
        scrollPhysics: this.carousel.options.scrollPhysics,
        pageSnapping: this.carousel.options.pageSnapping,
        pauseAutoPlayOnTouch: this.carousel.options.pauseAutoPlayOnTouch,
        pauseAutoPlayOnManualNavigate:
            this.carousel.options.pauseAutoPlayOnManualNavigate,
        pauseAutoPlayInFiniteScroll:
            this.carousel.options.pauseAutoPlayInFiniteScroll,
        pageViewKey: this.carousel.options.pageViewKey,
        enlargeStrategy: this.carousel.options.enlargeStrategy,
        disableCenter: this.carousel.options.disableCenter,
      );
      return this.carousel.itemBuilder != null
          ? CarouselSlider.builder(
              carouselController: controller,
              options: options,
              itemCount: this.carousel.itemCount,
              itemBuilder: this.carousel.itemBuilder,
            )
          : CarouselSlider(
              carouselController: controller,
              options: options,
              items: this.carousel.items,
            );
    });
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        carousel,
        if ((carousel.itemCount ?? 0) > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: AnimatedSmoothIndicator(
              activeIndex: currentCarouselIndex.value,
              count: carousel.itemCount ?? 0,
              effect: WormEffect(
                paintStyle: PaintingStyle.stroke,
                dotColor: theme.colorScheme.surface,
                activeDotColor: theme.colorScheme.surface,
                dotHeight: 8 * mediaQuery.textScaleFactor,
                dotWidth: 8 * mediaQuery.textScaleFactor,
              ),
              duration: carousel.options.autoPlayAnimationDuration,
              curve: carousel.options.autoPlayCurve,
              onDotClicked: (final index) async {
                await controller.animateToPage(
                  index,
                  duration: carousel.options.autoPlayAnimationDuration,
                  curve: carousel.options.autoPlayCurve,
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<CarouselSlider>('carousel', carousel)),
    );
  }
}
