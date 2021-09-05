import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/widgets/components/font_icon.dart';

/// The screen that shows a content on a similar template.
class ContentScreen extends HookWidget {
  /// The screen that shows a content on a similar template.
  const ContentScreen({
    required final this.carouselImages,
    final this.carouselOptions,
    final this.carouselController,
    final this.carouselBuilder,
    final Key? key,
  }) : super(key: key);

  /// The images to display in carousel.
  final Iterable<String> carouselImages;

  /// The controller for the carousel.
  final CarouselController? carouselController;

  /// The builder of the item in carousel.
  final ExtendedIndexedWidgetBuilder? carouselBuilder;

  /// The carousel options.
  final CarouselOptions? carouselOptions;

  @override
  Widget build(final BuildContext context) {
    final appBarTheme = AppBarTheme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: CustomScrollView(
        primary: true,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 280 - mediaQuery.viewPadding.top,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
            ),
            leading: const FontIconBackButton(),
            actions: <Widget>[
              FontIconButton(
                FontIcon(
                  FontIconData(
                    IconsCG.share,
                    color: appBarTheme.foregroundColor,
                    height: 24,
                    width: 24,
                  ),
                ),
                // onPressed: () => Share.share(),
              )
            ],
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _ContentCarousel(
                carouselImages,
                options: carouselOptions,
                controller: carouselController,
                builder: carouselBuilder,
              ),
            ),
          ),
          SliverToBoxAdapter(child: Column(children: <Widget>[])),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(IterableProperty<String>('carouselImages', carouselImages))
        ..add(
          DiagnosticsProperty<CarouselController?>(
            'carouselController',
            carouselController,
          ),
        )
        ..add(
          ObjectFlagProperty<ExtendedIndexedWidgetBuilder?>.has(
            'carouselBuilder',
            carouselBuilder,
          ),
        )
        ..add(
          DiagnosticsProperty<CarouselOptions?>(
            'carouselOptions',
            carouselOptions,
          ),
        ),
    );
  }
}

class _ContentCarousel extends HookWidget {
  const _ContentCarousel(
    final this.images, {
    final this.options,
    final this.controller,
    final this.builder,
    final Key? key,
  })  : assert(images.length > 0, 'Images can not be empty.'),
        super(key: key);

  final Iterable<String> images;
  final CarouselController? controller;
  final ExtendedIndexedWidgetBuilder? builder;
  final CarouselOptions? options;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final currentCarouselIndex = useState<int>(0);
    final options = this.options ??
        CarouselOptions(
          // aspectRatio: 2.7182818284,
          height: 280,
          autoPlay: true,
          autoPlayInterval: const Duration(minutes: 1),
          autoPlayAnimationDuration: const Duration(milliseconds: 500),
          autoPlayCurve: Curves.easeOut,
          enableInfiniteScroll: images.length > 1,
          viewportFraction: 1,
          onPageChanged: (final index, final reason) =>
              currentCarouselIndex.value = index,
        );

    final controller = this.controller ?? CarouselController();
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        CarouselSlider.builder(
          itemCount: images.length,
          itemBuilder: builder ??
              (final context, final index, final realIndex) {
                return CachedNetworkImage(
                  imageUrl: images.elementAt(index),
                  fit: BoxFit.cover,
                );
              },
          carouselController: controller,
          options: options,
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(left: 14, bottom: 8),
            child: AnimatedSmoothIndicator(
              activeIndex: currentCarouselIndex.value,
              count: images.length,
              effect: WormEffect(
                dotColor: Colors.transparent,
                activeDotColor: theme.colorScheme.surface,
                dotHeight: 8,
                dotWidth: 8,
              ),
              duration: options.autoPlayAnimationDuration,
              curve: options.autoPlayCurve,
              onDotClicked: (final index) async {
                await controller.animateToPage(
                  index,
                  duration: options.autoPlayAnimationDuration,
                  curve: options.autoPlayCurve,
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
        ..add(IterableProperty<String>('images', images))
        ..add(
          DiagnosticsProperty<CarouselController?>('controller', controller),
        )
        ..add(
          ObjectFlagProperty<ExtendedIndexedWidgetBuilder?>.has(
            'builder',
            builder,
          ),
        )
        ..add(DiagnosticsProperty<CarouselOptions?>('options', options)),
    );
  }
}
