import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:darq/darq.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/hooks/refresh_content_hook.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models/map_info_windows_options.dart';
import 'package:stretching/models/smstretching/sm_studio_model.dart';
import 'package:stretching/models/yclients/company_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/content_provider.dart';
import 'package:stretching/providers/firebase_providers.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/style.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/content_screen.dart';
import 'package:stretching/widgets/navigation/components/bottom_sheet.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// The provider of the current map state of the [StudiosScreen].
final StateProvider<bool> studiosOnMapProvider =
    StateProvider<bool>((final ref) => false);

/// The action of the [OpenContainer.closedBuilder] provider of the
/// [StudioScreenCard] for each [CombinedStudioModel].
final StateProviderFamily<void Function()?, CombinedStudioModel>
    studiosCardsProvider =
    StateProvider.family<void Function()?, CombinedStudioModel>(
  (final ref, final trainer) => null,
);

/// The screen for the [NavigationScreen.studios].
class StudiosScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.studios].
  const StudiosScreen({final Key? key}) : super(key: key);

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(55.751244, 37.618423),
    zoom: 12.5,
  );

  /// The duration of the switch of the [studiosOnMapProvider].
  static const Duration onMapSwitcherDuration = Duration(milliseconds: 500);

  /// The margin of the [StudioCard].
  static const EdgeInsetsGeometry studioCardMargin = EdgeInsets.only(bottom: 8);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final scrollController =
        ref.watch(navigationScrollControllerProvider(NavigationScreen.studios));
    final devicePixelRatio =
        Platform.isAndroid ? mediaQuery.devicePixelRatio : 1;

    final studios = ref.watch(combinedStudiosProvider);
    final mapMarker = ref.watch(
      mapMarkerProvider(
        FontIconData(
          IconsCG.pin,
          color: theme.colorScheme.onSurface,
          height: (20 + 20 / 3) * 4 * mediaQuery.textScaleFactor.clamp(0, 1.2),
        ),
      ),
    );

    final isMounted = useIsMounted();
    final isTransitioning = useState<bool>(false);
    final isMapCreated = useState<bool>(ref.read(studiosOnMapProvider).state);
    final onMap = ref.watch(
      studiosOnMapProvider.select((final onMap) {
        if (onMap.state && !isMapCreated.value) {
          isMapCreated.value = onMap.state;
        }
        return onMap;
      }),
    );
    final mapController = useState<GoogleMapController?>(null);
    final infoWindowOptions =
        useState<Tuple2<InfoWindowOptions, ScreenCoordinate>?>(null);
    final refreshKey = useMemoized(GlobalKey.new);
    final refresh = useRefreshController(
      extraRefresh: () async {
        while (ref.read(connectionErrorProvider).state) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      },
      notifiers: <ContentNotifier>[
        ref.read(studiosProvider.notifier),
        ref.read(smStudiosProvider.notifier),
        ref.read(smStudiosOptionsProvider.notifier),
      ],
    );
    useMemoized(
      () {
        final options = infoWindowOptions.value?.item0;
        if (options != null) {
          infoWindowOptions.value = Tuple2(
            options.copyWith(
              size: const Size(196, 42) * mediaQuery.textScaleFactor,
            ),
            infoWindowOptions.value!.item1,
          );
        }
      },
      [mediaQuery.textScaleFactor],
    );

    Future<void> moveToStudioOnMap(final StudioModel studio) async {
      final options = InfoWindowOptions(
        coordinates: LatLng(
          studio.coordinateLat,
          studio.coordinateLon,
        ),
        offset: const Offset(-40, 20),
        size: const Size(196, 42) * mediaQuery.textScaleFactor,
      );
      if (infoWindowOptions.value?.item0 != options) {
        final controller = mapController.value;
        if (controller != null) {
          infoWindowOptions.value = null;
          await Future<void>.delayed(const Duration(milliseconds: 100));
          infoWindowOptions.value = Tuple2(
            options,
            await controller.getScreenCoordinate(options.coordinates),
          );
        }
      }
    }

    Future<void> onMainStudioCardTap(final StudioModel studio) async {
      onMap.state = true;
      await mapController.value?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(studio.coordinateLat, studio.coordinateLon),
            zoom: _initialCameraPosition.zoom,
            bearing: _initialCameraPosition.bearing,
            tilt: _initialCameraPosition.tilt,
          ),
        ),
      );
      await mapController.value
          ?.showMarkerInfoWindow(MarkerId(studio.id.toString()));
      await moveToStudioOnMap(studio);
      await analytics.logEvent(
        name: FAKeys.studioOnMap,
        parameters: <String, String>{
          'type': 'map',
          'studio': translit(studio.title),
        },
      );
    }

    return PageTransitionSwitcher(
      duration: onMapSwitcherDuration,
      layoutBuilder: (final entries) => Stack(
        children: <Widget>[
          if (isMapCreated.value)
            GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              compassEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              mapToolbarEnabled: false,
              // onCameraMoveStarted: () {
              //   infoWindowOffset.value = Offset.zero;
              //   infoWindowOptions.value = null;
              // },
              markers: mapMarker.when(
                data: (final icon) => <Marker>{
                  for (final studio in studios)
                    Marker(
                      markerId: MarkerId(studio.item0.id.toString()),
                      position: LatLng(
                        studio.item0.coordinateLat,
                        studio.item0.coordinateLon,
                      ),
                      flat: true,
                      icon: icon,
                      onTap: () => moveToStudioOnMap(studio.item0),
                    )
                },
                loading: (final icon) => <Marker>{},
                error: (final error, final stackTrace, final icon) =>
                    <Marker>{},
              ),
              onTap: (final position) => infoWindowOptions.value = null,
              onCameraMove: (final position) async {
                final info = infoWindowOptions.value;
                final controller = mapController.value;
                if (info != null && controller != null) {
                  infoWindowOptions.value = Tuple2(
                    info.item0,
                    await controller
                        .getScreenCoordinate(info.item0.coordinates),
                  );
                }
              },
              onMapCreated: (final controller) async {
                final style = await ref.read(mapStyleProvider.future);
                await controller.setMapStyle(style);
                mapController.value = controller;
              },
            ),

          /// Location FAB
          Positioned(
            right: 24 * mediaQuery.textScaleFactor,
            bottom: 24 * mediaQuery.textScaleFactor,
            child: Transform.scale(
              scale: mediaQuery.textScaleFactor,
              child: FloatingActionButton.small(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () async {
                  final location = await ref.read(locationProvider.last);
                  await mapController.value?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(location.latitude, location.longitude),
                        zoom: _initialCameraPosition.zoom,
                        bearing: _initialCameraPosition.bearing,
                        tilt: _initialCameraPosition.tilt,
                      ),
                    ),
                  );
                },
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                child: const FontIcon(
                  FontIconData(IconsCG.mapLocation, height: 14),
                ),
              ),
            ),
          ),

          /// The custom info window.
          if (infoWindowOptions.value != null)
            Builder(
              builder: (final context) {
                final options = infoWindowOptions.value!.item0;
                final coordinates = infoWindowOptions.value!.item1;
                return Positioned(
                  left: (coordinates.x / devicePixelRatio) -
                      (options.offset.dx + options.size.width / 2),
                  top: (coordinates.y / devicePixelRatio) -
                      (options.offset.dy + options.size.height),
                  child: SizedBox.fromSize(
                    size: options.size,
                    child: StudioScreenCard(
                      studios.firstWhere((final studio) {
                        final coordinates = options.coordinates;
                        return studio.item0.coordinateLat.toStringAsFixed(6) ==
                                coordinates.latitude.toStringAsFixed(6) &&
                            studio.item0.coordinateLon.toStringAsFixed(6) ==
                                coordinates.longitude.toStringAsFixed(6);
                      }),
                    ),
                  ),
                );
              },
            ),

          /// Background
          if (!onMap.state) Container(color: theme.scaffoldBackgroundColor),

          /// Other Content
          ...entries,

          /// Switcher
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton.icon(
                    icon: const FontIcon(FontIconData(IconsCG.list)),
                    label: Text(TR.studiosViewList.tr()),
                    style: (onMap.state
                            ? TextButtonStyle.light.fromTheme(theme)
                            : TextButtonStyle.dark.fromTheme(theme))
                        .copyWith(
                      textStyle:
                          MaterialStateProperty.all(theme.textTheme.headline5),
                      visualDensity: VisualDensity.compact,
                      shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ),
                    onPressed: onMap.state && !isTransitioning.value
                        ? () async {
                            isTransitioning.value = !(onMap.state = false);
                            await Future<void>.delayed(onMapSwitcherDuration);
                            if (isMounted()) {
                              isTransitioning.value = false;
                            }
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton.icon(
                    icon: const FontIcon(FontIconData(IconsCG.pinOutline)),
                    label: Text(TR.studiosViewMap.tr()),
                    style: (onMap.state
                            ? TextButtonStyle.dark.fromTheme(theme)
                            : TextButtonStyle.light.fromTheme(theme))
                        .copyWith(
                      textStyle:
                          MaterialStateProperty.all(theme.textTheme.headline5),
                      visualDensity: VisualDensity.compact,
                      shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ),
                    onPressed: !onMap.state && !isTransitioning.value
                        ? () async {
                            isTransitioning.value = onMap.state = true;
                            await Future<void>.delayed(onMapSwitcherDuration);
                            if (isMounted()) {
                              isTransitioning.value = false;
                            }
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
      transitionBuilder: (
        final child,
        final animation,
        final secondaryAnimation,
      ) =>
          SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        fillColor: Colors.transparent,
        transitionType: SharedAxisTransitionType.scaled,
        child: AnimatedOpacity(
          opacity: !onMap.state ? 1 : 0,
          duration: onMapSwitcherDuration,
          curve: const Interval(0, 2 / 3, curve: Curves.ease),
          child: child,
        ),
      ),
      child: !onMap.state
          ? Padding(
              padding: const EdgeInsets.only(top: 72),
              child: SmartRefresher(
                key: refreshKey,
                controller: refresh.item0,
                onLoading: refresh.item0.loadComplete,
                onRefresh: () async {
                  try {
                    ref.refresh(locationProvider);
                    await ref.read(locationProvider.last);
                  } finally {
                    await refresh.item1();
                  }
                },
                scrollController: scrollController,
                child: ListView.builder(
                  controller: scrollController,
                  primary: false,
                  padding: const EdgeInsets.symmetric(horizontal: 16)
                      .copyWith(top: 8),
                  itemCount: studios.length,
                  itemBuilder: (final context, final index) => Padding(
                    padding: studioCardMargin,
                    child: StudioScreenCard(
                      studios.elementAt(index),
                      onNonMapTap: (final studio) async {
                        await onMainStudioCardTap(studio.item0);
                        await analytics.logEvent(
                          name: FAKeys.studioOnMap,
                          parameters: <String, String>{
                            'type': 'list',
                            'studio': translit(studio.item1.studioName),
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

/// The callback on a [StudioModel] and a [SMStudioModel].
typedef OnStudio = void Function(CombinedStudioModel studio);

/// The card for the [StudiosScreen].
class StudioScreenCard extends ConsumerWidget {
  /// The card for the [StudiosScreen].
  const StudioScreenCard(
    final this.studio, {
    final this.onNonMapTap,
    final Key? key,
  }) : super(key: key);

  /// The studio in the YClients API.
  final CombinedStudioModel studio;

  /// The callback to call on tap of this card if this widget is not on map.
  final OnStudio? onNonMapTap;

  /// The [OpenContainer.transitionDuration] of this widget.
  static const Duration transitionDuration = Duration(milliseconds: 500);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    return OpenContainer<void>(
      tappable: false,
      openElevation: 0,
      closedElevation: 0,
      openColor: Colors.transparent,
      closedColor: Colors.transparent,
      middleColor: Colors.transparent,
      transitionDuration: transitionDuration,
      openBuilder: (final context, final action) => ContentScreen(
        type: NavigationScreen.studios,
        onBackButtonPressed: action,
        title: studio.item1.studioName,
        subtitle: studio.item1.studioAddress,
        persistentFooterButtons: <Widget>[
          BottomButtons<void>(
            inverse: true,
            direction: Axis.horizontal,
            firstText: TR.studiosFind.tr(),
            onFirstPressed: (final context, final ref) =>
                Navigator.of(context).push(
              MaterialPageRoute(
                builder: (final builder) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: NavigationRoot.navBarHeight,
                  ),
                  child: Scaffold(
                    extendBodyBehindAppBar: true,
                    appBar: mainAppBar(
                      Theme.of(context),
                      leading: const FontIconBackButton(),
                    ),
                    body: WebView(
                      initialUrl: smStretchingUrl + studio.item1.studioUrlAbout,
                      javascriptMode: JavascriptMode.unrestricted,
                      navigationDelegate: (final navigation) =>
                          navigation.url.startsWith(smStretchingUrl)
                              ? NavigationDecision.navigate
                              : NavigationDecision.prevent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        paragraphs: <ContentParagraph>[
          ContentParagraph(
            title: TR.studiosTimetable.tr(),
            body: studio.item0.schedule.replaceAll('; ', '\n').trim(),
            expandable: false,
          ),
          ContentParagraph(
            title: TR.studiosAbout.tr(),
            body: studio.item1.about,
            expandable: false,
          ),
        ],
        carousel: CarouselSlider.builder(
          options: CarouselOptions(
            height: 280 + mediaQuery.viewPadding.top,
            viewportFraction: 1,
            enableInfiniteScroll: studio.item1.mediaGallerySite.length > 1,
          ),
          itemCount: studio.item1.mediaGallerySite.length,
          itemBuilder: (final context, final index, final realIndex) {
            final media = studio.item1.mediaGallerySite.elementAt(index);
            return CachedNetworkImage(
              imageUrl: media.url,
              fit: BoxFit.fitHeight,
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width,
              height: 280,
              errorWidget: (final context, final url, final dynamic error) =>
                  const SizedBox.shrink(),
            );
          },
        ),
      ),
      closedBuilder: (final context, final action) {
        Future<void> actionWithAnalytics() async {
          action();
          await analytics.logEvent(
            name: FAKeys.studioScreen,
            parameters: <String, String>{
              'studio': translit(studio.item1.studioName)
            },
          );
        }

        ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
          ref.read(studiosCardsProvider(studio)).state = action;
        });
        return StudioCard(
          studio,
          onMap: onNonMapTap == null,
          onTap: (final studio) => actionWithAnalytics(),
          onAvatarTap: onNonMapTap != null
              ? (final studio) => onNonMapTap?.call(studio)
              : null,
        );
      },
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<CombinedStudioModel>('studio', studio))
        ..add(ObjectFlagProperty<OnStudio?>.has('onNonMapTap', onNonMapTap)),
    );
  }
}

/// The card for the [StudioScreenCard].
class StudioCard extends HookConsumerWidget {
  /// The card for the [StudioScreenCard].
  const StudioCard(
    final this.studio, {
    final this.onTap,
    final this.onAvatarTap,
    final this.onMap = false,
    final Key? key,
  }) : super(key: key);

  /// The studio in the YClients API.
  final CombinedStudioModel studio;

  /// The callback to call on tap of this card.
  final OnStudio? onTap;

  /// The callback to call on tap of the avatar of this card.
  final OnStudio? onAvatarTap;

  /// If this is the on-map version of this card.
  final bool onMap;

  /// The inner padding of this widget.
  static EdgeInsets padding(
    final double textScaleFactor, {
    final bool onMap = false,
  }) =>
      EdgeInsets.symmetric(
        horizontal: (onMap ? 8 : 12) * textScaleFactor,
        vertical: (onMap ? 0 : 12) * textScaleFactor,
      );

  /// The padding of the avatar of this widget.
  static EdgeInsets avatarPadding({
    final bool onMap = false,
  }) =>
      EdgeInsets.all(onMap ? 2 : 4);

  /// The diameter of the avatar of this widget.
  static double avatarSize({
    final bool onMap = false,
  }) =>
      onMap ? 28 : 48;

  /// The overall height of this widget.
  static double height(
    final double textScaleFactor, {
    final bool onMap = false,
  }) =>
      padding(textScaleFactor, onMap: onMap).vertical +
      avatarPadding(onMap: onMap).vertical +
      avatarSize(onMap: onMap);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final currentLocation = ref.watch(locationProvider);
    return Material(
      elevation: onMap ? 10 : 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(onMap ? 4 : 8)) *
            mediaQuery.textScaleFactor,
        side: onMap ? const BorderSide() : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => onTap?.call(studio),
        borderRadius: BorderRadius.all(Radius.circular(onMap ? 4 : 8)) *
            mediaQuery.textScaleFactor,
        child: Padding(
          padding: padding(mediaQuery.textScaleFactor, onMap: onMap),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              /// Studio Avatar
              Padding(
                padding: avatarPadding(onMap: onMap).copyWith(
                  right: (onMap ? 6 : 8) * mediaQuery.textScaleFactor,
                ),
                child: CachedNetworkImage(
                  imageUrl: studio.avatarUrl,
                  height: avatarSize(onMap: onMap) * mediaQuery.textScaleFactor,
                  width: avatarSize(onMap: onMap) * mediaQuery.textScaleFactor,
                  imageBuilder: (final context, final imageProvider) =>
                      GestureDetector(
                    onTap: () => onAvatarTap?.call(studio),
                    child: CircleAvatar(
                      radius: (avatarSize(onMap: onMap) / 2) *
                          mediaQuery.textScaleFactor,
                      foregroundImage: imageProvider,
                    ),
                  ),
                  errorWidget:
                      (final context, final url, final dynamic error) =>
                          const SizedBox.shrink(),
                ),
              ),

              /// Info
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /// Studio Name
                    Text(
                      studio.item1.studioName,
                      style: theme.textTheme.bodyText1
                          ?.copyWith(fontSize: onMap ? 12 : null),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    /// Studio Address
                    Text(
                      studio.item1.studioAddress,
                      style: theme.textTheme.caption?.copyWith(
                        fontSize: onMap ? 10 : null,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    /// Distance To Studio
                    if (!onMap)
                      Flexible(
                        child: currentLocation.when<Widget>(
                          data: (final position) {
                            final distance =
                                GeolocatorPlatform.instance.distanceBetween(
                              position.latitude,
                              position.longitude,
                              studio.item0.coordinateLat,
                              studio.item0.coordinateLon,
                            );

                            final String text;
                            if (distance < 10) {
                              text = TR.studiosLocationOn.tr();
                            } else if (distance < 1000) {
                              text = TR.studiosLocationM.tr(
                                args: <String>[
                                  num.parse(
                                    distance.toStringAsFixed(
                                      distance < 100 ? 1 : 0,
                                    ),
                                  ).toString()
                                ],
                              );
                            } else {
                              final distanceInKm = distance / 1000;
                              text = TR.studiosLocationKm.tr(
                                args: <String>[
                                  num.parse(
                                    distanceInKm.toStringAsFixed(
                                      distanceInKm < 10
                                          ? 2
                                          : distanceInKm < 100
                                              ? 1
                                              : 0,
                                    ),
                                  ).toString()
                                ],
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                text,
                                style: theme.textTheme.caption
                                    ?.copyWith(color: Colors.grey.shade400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                          loading: (final position) => const SizedBox.shrink(),
                          error: (
                            final error,
                            final stackTrace,
                            final position,
                          ) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              /// Right Arrow
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FontIcon(
                    FontIconData(
                      IconsCG.angleRight,
                      height: (onMap ? 14 : 20) * mediaQuery.textScaleFactor,
                    ),
                  ),
                  if (!onMap) SizedBox(height: 4 * mediaQuery.textScaleFactor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<CombinedStudioModel>('studio', studio))
        ..add(ObjectFlagProperty<OnStudio?>.has('onTap', onTap))
        ..add(ObjectFlagProperty<OnStudio?>.has('onAvatarTap', onAvatarTap))
        ..add(DiagnosticsProperty<bool>('onMap', onMap)),
    );
  }
}
