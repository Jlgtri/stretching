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
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/hooks/refresh_content_hook.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models/map_info_windows_options.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_yclients/company_model.dart';
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

/// The screen for the [NavigationScreen.studios].
class StudiosScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.studios].
  const StudiosScreen({final Key? key}) : super(key: key);

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(55.751244, 37.618423),
    zoom: 12.5,
  );

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final scrollController = ModalScrollController.of(context);
    final devicePixelRatio =
        Platform.isAndroid ? mediaQuery.devicePixelRatio : 1;

    final studios = ref.watch(combinedStudiosProvider);
    final mapMarker = ref.watch(
      mapMarkerProvider(
        FontIconData(
          IconsCG.pin,
          color: theme.colorScheme.onSurface,
          height: (20 + 20 / 3) * 4,
        ),
      ),
    );

    final mapController = useState<GoogleMapController?>(null);
    final infoWindowOptions = useState<InfoWindowOptions?>(null);
    final screenCoordinates = useState<ScreenCoordinate?>(null);
    final onMap = useState<bool>(false);
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

    Future<void> moveToStudioOnMap(final StudioModel studio) async {
      final options = InfoWindowOptions(
        coordinates: LatLng(
          studio.coordinateLat,
          studio.coordinateLon,
        ),
        offset: const Offset(-40, 20),
        size: const Size(196, 42),
      );
      if (infoWindowOptions.value != options) {
        final controller = mapController.value;
        if (controller != null) {
          infoWindowOptions.value = screenCoordinates.value = null;
          await Future<void>.delayed(const Duration(milliseconds: 100));
          infoWindowOptions.value = options;
          screenCoordinates.value =
              await controller.getScreenCoordinate(options.coordinates);
        }
      }
    }

    Future<void> onMainStudioCardTap(final StudioModel studio) async {
      onMap.value = true;
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
      reverse: !onMap.value,
      duration: const Duration(milliseconds: 500),
      layoutBuilder: (final entries) => Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            compassEnabled: false,
            // myLocationEnabled: true,
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
              data: (final marker) => <Marker>{
                for (final studio in studios)
                  Marker(
                    markerId: MarkerId(studio.item0.id.toString()),
                    position: LatLng(
                      studio.item0.coordinateLat,
                      studio.item0.coordinateLon,
                    ),
                    flat: true,
                    icon: marker,
                    onTap: () => moveToStudioOnMap(studio.item0),
                  )
              },
              loading: () => <Marker>{},
              error: (final e, final st) => <Marker>{},
            ),
            onTap: (final position) =>
                infoWindowOptions.value = screenCoordinates.value = null,
            onCameraMove: (final position) async {
              final info = infoWindowOptions.value;
              final controller = mapController.value;
              if (info != null && controller != null) {
                screenCoordinates.value =
                    await controller.getScreenCoordinate(info.coordinates);
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
            right: 24,
            bottom: 24,
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

          /// The custom info window.
          if (infoWindowOptions.value != null &&
              screenCoordinates.value != null)
            Positioned(
              left: (screenCoordinates.value!.x / devicePixelRatio) -
                  (infoWindowOptions.value!.offset.dx +
                      infoWindowOptions.value!.size.width / 2),
              top: (screenCoordinates.value!.y / devicePixelRatio) -
                  (infoWindowOptions.value!.offset.dy +
                      infoWindowOptions.value!.size.height),
              child: SizedBox.fromSize(
                size: infoWindowOptions.value!.size,
                child: StudioScreenCard(
                  studios.firstWhere((final studio) {
                    final coordinates = infoWindowOptions.value!.coordinates;
                    return studio.item0.coordinateLat.toStringAsFixed(6) ==
                            coordinates.latitude.toStringAsFixed(6) &&
                        studio.item0.coordinateLon.toStringAsFixed(6) ==
                            coordinates.longitude.toStringAsFixed(6);
                  }),
                ),
              ),
            ),

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
                    style: (onMap.value
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
                    onPressed: () => onMap.value ? onMap.value = false : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton.icon(
                    icon: const FontIcon(FontIconData(IconsCG.pinOutline)),
                    label: Text(TR.studiosViewMap.tr()),
                    style: (onMap.value
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
                    onPressed: () => !onMap.value ? onMap.value = true : null,
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
      ) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Colors.transparent,
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        );
      },
      child: !onMap.value
          ? Material(
              color: theme.scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: SmartRefresher(
                  controller: refresh.item0,
                  onLoading: refresh.item0.loadComplete,
                  onRefresh: refresh.item1,
                  child: ListView.builder(
                    controller: scrollController,
                    primary: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemExtent: 88,
                    itemCount: studios.length,
                    itemBuilder: (final context, final index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
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
                      );
                    },
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

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return OpenContainer<void>(
      tappable: false,
      openElevation: 0,
      closedElevation: 0,
      openColor: Colors.transparent,
      closedColor: Colors.transparent,
      middleColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      openBuilder: (final context, final action) {
        return ContentScreen(
          type: NavigationScreen.studios,
          onBackButtonPressed: action,
          title: studio.item1.studioName,
          subtitle: studio.item1.studioAddress,
          persistentFooterButtons: <Widget>[
            BottomButtons<void>(
              inverse: true,
              direction: Axis.horizontal,
              firstText: TR.studiosFind.tr(),
              onFirstPressed: (final context) => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (final builder) {
                    return Padding(
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
                          initialUrl:
                              smStretchingUrl + studio.item1.studioUrlAbout,
                          javascriptMode: JavascriptMode.unrestricted,
                          navigationDelegate: (final navigation) {
                            return navigation.url.startsWith(smStretchingUrl)
                                ? NavigationDecision.navigate
                                : NavigationDecision.prevent;
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          paragraphs: <ContentParagraph>[
            Tuple2(
              TR.studiosTimetable.tr(),
              studio.item0.schedule.replaceAll('; ', '\n').trim(),
            ),
            Tuple2(TR.studiosAbout.tr(), studio.item1.about),
          ],
          carousel: CarouselSlider.builder(
            options: CarouselOptions(
              height: 280,
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
              );
            },
          ),
        );
      },
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

        return StudioCard(
          studio,
          onMap: onNonMapTap == null,
          onTap: (final studio) => onNonMapTap == null
              ? actionWithAnalytics()
              : onNonMapTap?.call(studio),
          onAvatarTap: onNonMapTap != null
              ? (final studio) => actionWithAnalytics()
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

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocation = ref.watch(locationProvider);
    return Material(
      elevation: onMap ? 10 : 0,
      borderRadius: BorderRadius.all(Radius.circular(onMap ? 4 : 8)),
      child: ListTile(
        onTap: () => onTap?.call(studio),
        dense: onMap,
        enableFeedback: true,
        contentPadding: EdgeInsets.symmetric(horizontal: onMap ? 8 : 16),
        visualDensity: onMap ? VisualDensity.compact : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(onMap ? 4 : 8)),
          side: onMap ? const BorderSide() : BorderSide.none,
        ),
        tileColor: theme.colorScheme.surface,
        selectedTileColor: theme.colorScheme.surface,
        focusColor: theme.colorScheme.surface.withOpacity(2 / 3),
        hoverColor: theme.colorScheme.surface.withOpacity(2 / 3),
        horizontalTitleGap: onMap ? 8 : null,
        leading: CachedNetworkImage(
          imageUrl: studio.avatarUrl,
          alignment: Alignment.topCenter,
          height: (onMap ? 16 : 24) * 2,
          width: (onMap ? 16 : 24) * 2,
          imageBuilder: (final context, final imageProvider) {
            return IgnorePointer(
              ignoring: onAvatarTap == null,
              child: MaterialButton(
                onPressed: () => onAvatarTap?.call(studio),
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
                minWidth: (onMap ? 16 : 24) * 2,
                child: CircleAvatar(
                  radius: onMap ? 16 : 24,
                  foregroundImage: imageProvider,
                ),
              ),
            );
          },
        ),
        title: Padding(
          padding: EdgeInsets.only(top: !onMap ? 8 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                studio.item1.studioName,
                style: theme.textTheme.bodyText1
                    ?.copyWith(fontSize: onMap ? 12 : null),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                studio.item1.studioAddress,
                style: theme.textTheme.caption?.copyWith(
                  fontSize: onMap ? 10 : null,
                  color: Colors.grey.shade700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!onMap) ...[
                const SizedBox(height: 2),
                Text(
                  currentLocation.when<String>(
                    data: (final position) {
                      final distance =
                          GeolocatorPlatform.instance.distanceBetween(
                        position.latitude,
                        position.longitude,
                        studio.item0.coordinateLat,
                        studio.item0.coordinateLon,
                      );
                      if (distance < 10) {
                        return TR.studiosLocationOn.tr();
                      } else if (distance < 1000) {
                        return TR.studiosLocationM.tr(
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
                        return TR.studiosLocationKm.tr(
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
                    },
                    loading: () => '',
                    error: (final e, final st) => '',
                  ),
                  style: theme.textTheme.caption
                      ?.copyWith(color: Colors.grey.shade400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FontIcon(
              FontIconData(
                IconsCG.angleRight,
                height: onMap ? 14 : 20,
              ),
            ),
            if (!onMap) const SizedBox(height: 10),
          ],
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
